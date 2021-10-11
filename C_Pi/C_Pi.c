/*
  シリアル π コード

  このプログラムは、シリアルコンピューティング
  を使用して円周率を計算します。 

  作者: Carlos R. Morrison
  作成日付: 2017年7月14日

  翻訳: Tasuku Hori
  翻訳日付: 2021年10月11日
*/

#include <math.h>
#include <stdio.h>


int main(void)
{
  long num_rects = 300000;//1000000000;
  long i;
  double x,height,width,area;
  double sum;
 
  width = 1.0/(double)num_rects; // セグメント幅(dx)
  
  sum = 0;
  for(i = 0; i < num_rects; i++)
  {
    x = (i+0.5) * width; // i番目のセグメント幅中央距離にあるX座標
    height = 4/(1.0 + x*x);
    sum += height; // 個々のセグメント長総和
  }
  
// セグメントの面積概算（π値）
  area = width * sum;
  
  printf("\n");
  printf(" Calculated Pi = %.16f\n", area);
  printf("          M_PI = %.16f\n", M_PI);
  printf("Relative error = %.16f\n", fabs(area - M_PI));
  printf("\n");
  return 0;
}

