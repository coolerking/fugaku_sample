# MNIST サンプルコード

0から9までの手書き文字を分類するサンプルコード。

|種類|パス|富岳での実行|説明|
|:---|:---|:---|:---|
|逐次処理|[`mnist_dist.py`](./mnist_dist.py)|○| TensorFlowサイトのチュートリアルから引用。`python mnist_dist.py`で実行する|
|並列処理 MPMD|[Distributed TensorFlow](./distributed_tensorflow)|×|チュートリアルからの引用コード。`MirroredStrategy`（単一ノード）での実装。富岳計算ノード上ではトレーニングループの1回目ループでSegmentation Faultが発生。|
|並列処理 SPMD|[Horovod](./horovod)|○|Horovodサンプルコードより引用。富岳の複数の計算ノードでも実行可能。|
