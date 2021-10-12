/*
 MPI版 π コード
 
 この数値積分は、MPIを使用して円周率を
 計算します。 収束は非常に遅く、
 小数点以下48桁の精度を得るには
 500万回の反復が必要です

 作者: Carlos R. Morrison
 作成日付: 2017年1月14日

 翻訳: Tasuku Hori
 翻訳日付: 2021年10月11日
*/

#include <mpi.h>   // (Open)MPIライブラリ
#include <math.h>  // math ライブラリ
#include <stdio.h> // 標準入出力ライブラリ

int main(int argc, char*argv[])
{
  int total_iter;
  int n, rank, length, numprocs, i;
  double pi, width, sum, x, rank_integral;
  char hostname[MPI_MAX_PROCESSOR_NAME];

  MPI_Init(&argc, &argv);                    // MPI初期化
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);  // プロセス数の取得
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);      // 現在のプロセスIDの取得
  MPI_Get_processor_name(hostname, &length); // ホスト名の取得

  if (rank == 0)
  {
    printf("\n");
    printf("#######################################################");  
    printf("\n\n");
    printf("Master node name: %s\n", hostname); 
    printf("\n");
    printf("Enter number of segments:\n");
    printf("\n");
    scanf("%d",&n); // セグメント数の入力
    printf("\n");
  }

// セグメント数(n)をすべてのプロセスにブロードキャスト
  MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD); 

// このループは最大反復回数をインクリメントするため、
// プロセッサの計算速度をテストするための追加の作業が提供される
  for(total_iter = 1; total_iter < n; total_iter++) 
  {
    sum=0.0;
    width = 1.0 / (double)total_iter; // セグメント幅(dx)
//    width = 1.0 / (double)n; // width of a segment
      
    for(i = rank + 1; i <= total_iter; i += numprocs)
//    for(i = rank + 1; i <= n; i += numprocs)
    {
      x = width * ((double)i - 0.5); // i番目セグメントのx座標中央値
      sum += 4.0/(1.0 + x*x); // 与えられたランクにおける個々のセグメントの高さ(y)合計
    }

// 与えられたランクにおけるセグメントのおおよその面積(π)
    rank_integral = width * sum; 

// すべてのプロセスから部分面積（π）値を収集して追加
    MPI_Reduce(&rank_integral, &pi, 1, MPI_DOUBLE,MPI_SUM, 0, MPI_COMM_WORLD);

  } // for(total_iter = 1; total_iter < n; total_iter++) の終わり

// printf("Process %d on %s has the partial result of %.16f \n",rank,hostname,
//                                                              rank_integral);

  if(rank == 0)
  {
    printf("\n\n");
    printf("*** Number of processes: %d\n",numprocs);
    printf("\n\n");
    printf("     Calculated pi = %.50f\n", pi);
    printf("              M_PI = %.50f\n", M_PI);    
    printf("    Relative Error = %.50f\n", fabs(pi-M_PI));
    printf("\n");
  }

  // MPIのクリンナップと終了処理
  MPI_Finalize();
  return 0;  
}

