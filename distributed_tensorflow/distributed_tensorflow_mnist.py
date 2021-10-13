"""
Distributed TensorFlow サンプル MNIST

以下のサイトのコードより引用、加筆：
https://github.com/tensorflow/docs-l10n/blob/master/site/ja/tutorials/distribute/custom_training.ipynb
"""
## 1. TensorFlowのインポート
import tensorflow as tf

import numpy as np
import os

print("TensorFlow version")
print(tf.__version__)

print("1. end")

## 2. Fashion MNIST データセットのダウンロード

fashion_mnist = tf.keras.datasets.fashion_mnist

(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

# 配列へのディメンション追加 → 新しい形状: (28, 28, 1)
# 最初のレイヤが畳み込みで、
# 4D入力 (batch_size, height, width, channels) が必要なため。
# batch_sizeディメンションは後で追加される
train_images = train_images[..., None]
test_images = test_images[..., None]

# 範囲[0, 1]内のfloat値イメージ取得
train_images = train_images / np.float32(255)
test_images = test_images / np.float32(255)

print("2. end")

## 3. 変数とグラフを分散させるストラテジを作成

# デバイスリストが `tf.distribute.MirroredStrategy`コンストラクタで
# 指定されていない場合、自動検出される
strategy = tf.distribute.MirroredStrategy()
print ('Number of devices: {}'.format(strategy.num_replicas_in_sync))
print("3. end")
## 4. 入力パイプラインのセットアップ

BUFFER_SIZE = len(train_images)

BATCH_SIZE_PER_REPLICA = 64
GLOBAL_BATCH_SIZE = BATCH_SIZE_PER_REPLICA * strategy.num_replicas_in_sync

EPOCHS = 10

# データセットの作成
train_dataset = tf.data.Dataset.from_tensor_slices((train_images, train_labels)).shuffle(BUFFER_SIZE).batch(GLOBAL_BATCH_SIZE) 
test_dataset = tf.data.Dataset.from_tensor_slices((test_images, test_labels)).batch(GLOBAL_BATCH_SIZE) 

train_dist_dataset = strategy.experimental_distribute_dataset(train_dataset)
test_dist_dataset = strategy.experimental_distribute_dataset(test_dataset)
print("4. end")
## 5. モデルの作成
def create_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(32, 3, activation='relu'),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(64, 3, activation='relu'),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(10)
    ])
    return model

# チェックポイント保存用ディレクトリの作成
checkpoint_dir = './training_checkpoints'
checkpoint_prefix = os.path.join(checkpoint_dir, "ckpt")
print("5. end")
## 6. 損失関数の定義

# 単一のCPU/GPUの場合、損失は入力バッチサンプル数で除算される
# 分散ストラテジの場合は
# - 4GPU、バッチサイズ64の場合、1つの入力バッチは4つに分散されるので各レプリカは16の入力になる
# - 各レプリカモデルは、各々の入力でフォワードパスを実行し、損失を計算するが、
#   それぞれの入力サンプル数(BATCH_SIZE_PER_REPLICA=16)で除算するのではなく
#   損失をGLOBAL_BATCH_SIZE(=64)で除算する必要がある

with strategy.scope():
    # リダクションを `none`に設定して、後でリダクションを実行し、
    # グローバルバッチサイズで除算できるようにする
    loss_object = tf.keras.losses.SparseCategoricalCrossentropy(
        from_logits=True,
        reduction=tf.keras.losses.Reduction.NONE)
    def compute_loss(labels, predictions):
        per_example_loss = loss_object(labels, predictions)
        return tf.nn.compute_average_loss(per_example_loss, global_batch_size=GLOBAL_BATCH_SIZE)
print("6. end")
## 7. 損失と精度を追跡するメトリクスを定義
with strategy.scope():
    test_loss = tf.keras.metrics.Mean(name='test_loss')

    train_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(
        name='train_accuracy')
    test_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(
        name='test_accuracy')
print("7. end")
## 8. トレーニングループ
# model, optimizer, checkpoint は `strategy.scope` の下で作成
with strategy.scope():
    model = create_model()

    optimizer = tf.keras.optimizers.Adam()

    checkpoint = tf.train.Checkpoint(optimizer=optimizer, model=model)
print("8.1. end")
def train_step(inputs):
    images, labels = inputs

    with tf.GradientTape() as tape:
        predictions = model(images, training=True)
        loss = compute_loss(labels, predictions)

    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))

    train_accuracy.update_state(labels, predictions)
    return loss 

def test_step(inputs):
    images, labels = inputs

    predictions = model(images, training=False)
    t_loss = loss_object(labels, predictions)

    test_loss.update_state(t_loss)
    test_accuracy.update_state(labels, predictions)

# `run`は、提供された計算を複製し、分散入力を使って実行する
@tf.function
def distributed_train_step(dataset_inputs):
    # トレーニング１ステップの処理
    per_replica_losses = strategy.run(train_step, args=(dataset_inputs,))
    return strategy.reduce(
        tf.distribute.ReduceOp.SUM, 
        per_replica_losses, axis=None)

@tf.function
def distributed_test_step(dataset_inputs):
    # テスト１ステップの処理
    return strategy.run(test_step, args=(dataset_inputs,))
print("8.2. end")
for epoch in range(EPOCHS):
    # トレーニングループ
    total_loss = 0.0
    num_batches = 0
    for x in train_dist_dataset:
        total_loss += distributed_train_step(x)
        num_batches += 1
    train_loss = total_loss / num_batches

    # テストループ
    for x in test_dist_dataset:
        distributed_test_step(x)

    if epoch % 2 == 0:
        checkpoint.save(checkpoint_prefix)

    template = ("Epoch {}, Loss: {}, Accuracy: {}, Test Loss: {}, "
        "Test Accuracy: {}")
    print (template.format(
        epoch+1, train_loss,
        train_accuracy.result()*100, test_loss.result(),
        test_accuracy.result()*100))

    test_loss.reset_states()
    train_accuracy.reset_states()
    test_accuracy.reset_states()
    print("8.3. epoch loop {} step end".format(str(epoch)))
print("8. end")
## 9. 最新チェックポイントを復元しテスト
eval_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(
    name='eval_accuracy')

new_model = create_model()
new_optimizer = tf.keras.optimizers.Adam()

test_dataset = tf.data.Dataset.from_tensor_slices((test_images, test_labels)).batch(GLOBAL_BATCH_SIZE)

@tf.function
def eval_step(images, labels):
    # テスト1ステップの処理
    predictions = new_model(images, training=False)
    eval_accuracy(labels, predictions)

checkpoint = tf.train.Checkpoint(optimizer=new_optimizer, model=new_model)
checkpoint.restore(tf.train.latest_checkpoint(checkpoint_dir))
print("9.1. end")
for images, labels in test_dataset:
    eval_step(images, labels)

# 分散ストラテジなしで保存されたモデルを復元した後の精度を表示
print ('Accuracy after restoring the saved model without strategy: {}'.format(
    eval_accuracy.result()*100))
print("9. end")
## 10. データセットのイテレーションの代替方法
'''
# イテレータの使用
# データセット全体ではなく、任意のステップ数のイテレーションを行いたい場合は、
# iter呼び出しを使用してイテレータを作成し、そのイテレータ上でnextを明示的に
# 呼び出すことができます。
# tf.function の内側と外側の両方でデータセットのイテレーションを選択する
# ことができます。
# ここでは、イテレータを使用し tf.function 外側のデータセットの
# イテレーションを実行する小さなスニペットを示します。
for _ in range(EPOCHS):
    total_loss = 0.0
    num_batches = 0
    train_iter = iter(train_dist_dataset)

    for _ in range(10):
        total_loss += distributed_train_step(next(train_iter))
        num_batches += 1
    average_train_loss = total_loss / num_batches

    template = ("Epoch {}, Loss: {}, Accuracy: {}")
    print (template.format(epoch+1, average_train_loss, train_accuracy.result()*100))
    train_accuracy.reset_states()

# tf.function 内でのイテレーション
# tf.function の内側で for 文（for x in ...）を使用して、
# あるいは上記で行ったようにイテレータを作成して、
# 入力train_dist_dataset全体をイテレーションすることもできます。
# 次の例では、トレーニングの 1 つのエポックを tf.function でラップし、
# 関数内でtrain_dist_datasetをイテレーションする方法を示します。
@tf.function
def distributed_train_epoch(dataset):
    total_loss = 0.0
    num_batches = 0
    for x in dataset:
        per_replica_losses = strategy.run(train_step, args=(x,))
        total_loss += strategy.reduce(
            tf.distribute.ReduceOp.SUM, per_replica_losses, axis=None)
        num_batches += 1
    return total_loss / tf.cast(num_batches, dtype=tf.float32)

for epoch in range(EPOCHS):
    train_loss = distributed_train_epoch(train_dist_dataset)

    template = ("Epoch {}, Loss: {}, Accuracy: {}")
    print (template.format(epoch+1, train_loss, train_accuracy.result()*100))

    train_accuracy.reset_states()
'''