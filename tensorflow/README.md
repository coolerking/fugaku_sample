# 富岳上に tkinter が使用可能な TensorFlow 2.2.0 をインストールする方法

2021/12/09 時点における富岳環境では、TensorFlow 2.2.0 が使用可能であるが、有効にした場合の Python は tkinterが使用できない。

富岳上で動作する TensorFlow 2.2.0 のソースコードは、以下のリポジトリにて管理されている TensorFlow ブランチとして公開されている。

- [GitHub fujitsu/tensorflow](https://github.com/fujitsu/tensorflow)

上記サイトのWikiに、日本語のセットアップ手順が掲載されており、この手順通りに実行することで tkinter が無効な TensorFlow 2.2.0 実行環境をホームディレクトリ上に構築することができる。

本リポジトリでは上記のサイトを使って tkinter が有効な Python 管理下での TensorFlow 2.2.0 実行環境を構築する手段を提供する。

## 注意

本リポジトリは、2021/12/09 時点の富岳環境での動作を確認している。

富岳は、随時かつ頻繁に環境更新がおこなわれているため、本リポジトリの情報がすでに使用できない可能性がある。
使用の際は、各自の責任にて判断のこと。

## インストール手順

- 計算ノードへログイン
- 以下のコマンドを実行

  ```bash
  cd ${HOME}
  mkdir projects
  cd projects
  git clone https://github.com/coolerking/fugaku_sample
  cd fugaku_sample
  git checkout master
  cd tensorflow
  ```

- [`env.src_fugaku`](./env.src_fugaku) を確認する。`env.src` は、デフォルトの設定から以下の環境変数を変更している。必要に応じて値を変更する。
  - `PREFIX` : バイナリおよびライブラリの配置先ディレクトリ
  - `TCSDS_PATH` : 富士通コンパイラのベースディレクトリ（定期的にバージョンが更新される）
  - `VENV_NAME` : Python venv環境の配置先ディレクトリ

    ```bash
    PREFIX=${HOME}/.local/aarch64
    TCSDS_PATH=/opt/FJSVxtclanga/tcsds-1.2.33
    VENV_PATH=${HOME}/.local/aarch64/venv/tensorflow
    ```

- [`01_tensorflow.sh`](./01_tensorflow.sh) を確認する。有効なメールアドレスへの書き換えを行う。

  ```bash
  #PJM --mail-list "hogehoge@fugafuga.slack.com"
  ```

- 以下のコマンド実行

  ```bash
  chmod +x 01_tensorflow
  pjsub 01_tensorflow.sh
  ```

  試行時は、ジョブ開始から完了まで7時間半ほどかかった。

## TensorFlow 2.2.0 の利用

以下のコマンドを実行し、venv環境 `tensorflow` を有効化する。

```bash
source ${HOME}/.local/aarch64/venv/tensorflow/bin/activate
```

## ライセンス

[Apache2.0 ライセンス](../LICENSE) 準拠とする。
