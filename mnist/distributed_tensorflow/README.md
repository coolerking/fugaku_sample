# Distributed TensorFlow MNIST サンプル

> **注意**
>
> 富岳上での動作を確認していません。

- [`distributed_tensorflow_mnist.py`](./distributed_tensorflow_mnist.py): 
[GitHub tensorflow/docs-l10n](https://github.com/tensorflow/docs-l10n/blob/master/site/ja/tutorials/distribute/custom_training.ipynb) にあるサンプルコードを修正加筆したものです。

x86_64 アーキテクチャのWindows10 PC上では動作を確認しましたが、富岳上で会話形ジョブ形式で実行すると Segmentation Fault でepochループの1ループ目で停止します。

## ローカルPCで実行

コンソール表示(2021/10/13 実行)：

```bash
(tensorflow) D:\projects\ratf\fugaku_sample\distributed_tensorflow>python distributed_tensorflow_mnist.py
TensorFlow version
2.3.0
1. end
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-labels-idx1-ubyte.gz
32768/29515 [=================================] - 0s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-images-idx3-ubyte.gz
26427392/26421880 [==============================] - 2s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-labels-idx1-ubyte.gz
8192/5148 [===============================================] - 0s 0us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-images-idx3-ubyte.gz
4423680/4422102 [==============================] - 0s 0us/step
2. end
2021-10-13 14:32:23.525217: I tensorflow/core/platform/cpu_feature_guard.cc:142] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN)to use the following CPU instructions in performance-critical operations:  AVX AVX2
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
WARNING:tensorflow:There are non-GPU devices in `tf.distribute.Strategy`, not using nccl allreduce.
Number of devices: 1
3. end
2021-10-13 14:32:23.737693: W tensorflow/core/framework/cpu_allocator_impl.cc:81] Allocation of 188160000 exceeds 10% of free system memory.
4. end
5. end
6. end
7. end
8.1. end
8.2. end
2021-10-13 14:32:24.052351: W tensorflow/core/framework/cpu_allocator_impl.cc:81] Allocation of 188160000 exceeds 10% of free system memory.
WARNING:tensorflow:From C:\Users\89004\Anaconda3\envs\tensorflow\lib\site-packages\tensorflow\python\data\ops\multi_device_iterator_ops.py:601: get_next_as_optional (from tensorflow.python.data.ops.iterator_ops) is deprecated and will be removed in a future version.
Instructions for updating:
Use `tf.data.Iterator.get_next_as_optional()` instead.
Epoch 1, Loss: 0.5048527717590332, Accuracy: 81.73833465576172, Test Loss: 0.40285420417785645, Test Accuracy: 85.69999694824219
8.3. epoch loop 0 step end
2021-10-13 14:33:11.614740: W tensorflow/core/framework/cpu_allocator_impl.cc:81] Allocation of 188160000 exceeds 10% of free system memory.
Epoch 2, Loss: 0.32605308294296265, Accuracy: 88.22333526611328, Test Loss: 0.3276521563529968, Test Accuracy: 88.16999816894531
8.3. epoch loop 1 step end
2021-10-13 14:33:56.876105: W tensorflow/core/framework/cpu_allocator_impl.cc:81] Allocation of 188160000 exceeds 10% of free system memory.
Epoch 3, Loss: 0.28620755672454834, Accuracy: 89.54000091552734, Test Loss: 0.29048553109169006, Test Accuracy: 89.45000457763672
8.3. epoch loop 2 step end
2021-10-13 14:34:38.595103: W tensorflow/core/framework/cpu_allocator_impl.cc:81] Allocation of 188160000 exceeds 10% of free system memory.
Epoch 4, Loss: 0.25454750657081604, Accuracy: 90.6683349609375, Test Loss: 0.2951032817363739, Test Accuracy: 89.20000457763672
8.3. epoch loop 3 step end
Epoch 5, Loss: 0.22854840755462646, Accuracy: 91.54666900634766, Test Loss: 0.2878493666648865, Test Accuracy: 89.68000030517578
8.3. epoch loop 4 step end
Epoch 6, Loss: 0.20955389738082886, Accuracy: 92.17500305175781, Test Loss: 0.25967344641685486, Test Accuracy: 90.10000610351562
8.3. epoch loop 5 step end
Epoch 7, Loss: 0.194416806101799, Accuracy: 92.73500061035156, Test Loss: 0.26696622371673584, Test Accuracy: 90.10000610351562
8.3. epoch loop 6 step end
Epoch 8, Loss: 0.17601223289966583, Accuracy: 93.41999816894531, Test Loss: 0.25285136699676514, Test Accuracy: 90.76000213623047
8.3. epoch loop 7 step end
Epoch 9, Loss: 0.16044478118419647, Accuracy: 94.05000305175781, Test Loss: 0.2667485475540161, Test Accuracy: 90.83000183105469
8.3. epoch loop 8 step end
Epoch 10, Loss: 0.14942865073680878, Accuracy: 94.45999908447266, Test Loss: 0.2590740919113159, Test Accuracy: 91.04000091552734
8.3. epoch loop 9 step end
8. end
9.1. end
Accuracy after restoring the saved model without strategy: 90.83000183105469
9. end

(tensorflow) D:\projects\ratf\fugaku_sample\distributed_tensorflow>dir
 ドライブ D のボリューム ラベルがありません。
 ボリューム シリアル番号は 14D0-FDB7 です

 D:\projects\ratf\fugaku_sample\distributed_tensorflow のディレクトリ

2021/10/13  14:33    <DIR>          .
2021/10/13  14:33    <DIR>          ..
2021/10/13  14:29             9,760 distributed_tensorflow_mnist.py
2021/10/13  14:40    <DIR>          training_checkpoints
               1 個のファイル               9,760 バイト
               3 個のディレクトリ  772,679,680,000 バイトの空き領域

(tensorflow) D:\projects\ratf\fugaku_sample\distributed_tensorflow>
```

## 富岳(会話形ジョブ)で実行

コンソール表示(2021/10/13 実行)：

```bash
[hogehoge@k34-0008c distributed_tensorflow]$ which python3
/home/apps/oss/TensorFlow-2.2.0/bin/python3
[hogehoge@k34-0008c distributed_tensorflow]$ python3 dist_tf_mnist.py
TensorFlow version
2.2.0
1. end
2. end
2021-10-13 14:59:25.874981: I tensorflow/core/common_runtime/process_util.cc:147] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
WARNING:tensorflow:There are non-GPU devices in `tf.distribute.Strategy`, not using nccl allreduce.
Number of devices: 1
3. end
4. end
5. end
6. end
7. end
8.1. end
8.2. end
Segmentation fault
[hogehoge@k34-0008c distributed_tensorflow]$
```

なお、チェックポイントディレクトリも作成されず、`core` についても実行カレントディレクトリにもTMPDIR内には存在しなかった(`find $TMPDIR -name core -print`にて確認済み)。
