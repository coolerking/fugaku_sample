# 富岳サンプルコード

## 富岳上で動かすためのサンプルコード

|計算内容|種類|富岳での実行|説明|
|:--|:--|:-:|:--|
|[πの算出](./pi/serial)|逐次処理|○|Cによる実装|
|[πの算出](./pi/multi)|並列処理(SPMD)|○|C/MPIによる実装|
|[MNIST/TensorFlow](./mnist)|逐次処理|○|TensorFlowチュートリアルからの引用|
|[MNIST/TensorFlow/Horovod](./mnist/horovod)|並列処理(SPMD)|○|Horovodサンプルコードからの引用|
|[MNIST/Distributed TensorFlow](./mnist/distributed_tensorflow)|並列処理(MPMD|×|Distributed TensorFlowチュートリアル(`MirroredStrategy`)からの引用、富岳では動作しないがPCでは動作する|

- 富岳上で実行可能なコードについてはジョブスクリプトも公開
- C言語実装は`Makefile`も公開

## 貧岳 pugaku

- [貧岳 pugaku](./pugaku)

Raspberry Pi で作成したクラスタ上に富岳に近いソフトウェアを適用する方法について解説。

## Spack チュートリアル

- [Spackチュートリアルv0.16.2日本語訳](https://github.com/coolerking/spack_tutorial_v0.16.2_jpn)：別リポジトリにて提供

（2021年10月16日時点の）富岳では、Spack v0.16.2 富岳用ブランチをもちいたOSS提供を行っている。
富岳が提供している範囲内のパッケージの運用（パブリンクインスタンスのみで`spack load` しかつかわない、など）であればマニュアル記載の機能のみでもかまわないが、そうでない場合はSpackの機能を理解してからの操作のほうが作業時間が削減できる。
