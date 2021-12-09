# 貧岳計算ノード(node0[2-4])インストール手順

## 必要なもの

- Raspberry Pi本体×3（同じ仕様のもの推奨）
- SDカード×3
- 電源用USBケーブルとACアダプタ×3
- 有線LANケーブル×3
- ネットワークハブ（貧岳全体で1つ)
- インターネット接続可能なWiFiルータ（貧岳全体で1つ)

## OS起動

- ログインノード用Raspberry PiにLANケーブルを接続しネットワークハブに接続
- SDカードをSDCardフォーマッタなどでフォーマット
- https://www.raspberrypi.com/software/ から最新版Raspberry Pi OS Lite イメージをダウンロード＆展開
- Win32DiskImagerなどでSDカードへイメージ書き込み
- SDカードルートディレクトリ上に空のファイル `ssh` を作成
- SDカードルートディレクトリ上に `wpa_supplicant.conf` を作成し以下のようにWiFiルータ設定を書き込み保存

```sh
country=JP
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="WiFiルータのSSID名"
    psk="WiFiルータのパスフレーズ"
}
```

- ログインノード用Raspberry PiへSDカード挿入し電源ON

## OS セットアップ

> `sudo` 可能な `pi` ユーザにて作業を実施

- `sudo apt-get update && sudo apt-get upgrade -y`
- `sudo raspi-config` を実行し以下の設定を実施
  - hostnameに `node02` ～ `node04` を設定
  - `pi` ユーザのパスワードを設定（全ノード同じにしておくと楽）
  - 使用するインターフェイスを有効化（Camera、I2C、Wireress GPIOなど)
  - OpenGLを使用する場合などは GL>Fake GL
- `raspi-config` 終了時に再起動を選択し、再起動
- `sudo apt-get install -y build-essential python3 python3-dev python3-pip python3-virtualenv python3-numpy python3-picamera python3-pandas python3-rpi.gpio i2c-tools avahi-utils joystick libopenjp2-7-dev libtiff5-dev gfortran libatlas-base-dev libopenblas-dev libhdf5-serial-dev libgeos-dev git ntp libilmbase-dev libopenexr-dev libgstreamer1.0-dev libjasper-dev libwebp-dev libatlas-base-dev libavcodec-dev libavformat-dev libswscale-dev libqtgui4 libqt4-test ntpdate nfs-kernel-server mailutils`
- `sudo vi /etc/hosts` を実行し以下の行を追加

```sh
## pugaku
10.0.0.1 node01
10.0.0.2 node02
10.0.0.3 node03
10.0.0.4 node04
```

- `sudo vi /etc/dhcpcd.conf` を実行し以下の行を挿入

`node02` の場合：

```sh
interface eth0
static ip_address=10.0.0.2/8
```

`node03` の場合：

```sh
interface eth0
static ip_address=10.0.0.3/8
```

`node04` の場合：

```sh
interface eth0
static ip_address=10.0.0.4/8
```

- 以下のコマンドを実行し、作業用共有ディレクトリを作成

```bash
sudo mkdir /clusterfs
sudo chown nobody.nogroup -R /clusterfs
sudo chmod 777 -R /clusterfs
```

- `sudo reboot` を実行し再度ログイン
- `ping node01` を実行して、ネットワーク設定が有効かどうかを確認
- `sudo vi /etc/fstab` を実行し以下の2行を追加

```sh
node01:/home      /home       nfs defaults 0 0
node01:/clusterfs /clusterfs  nfs defaults 0 0
```

- `sudo mount -a` を実行しマウント
- `df` でマウントされているか確認

## Slurm クライアントのインストール

- `sudo apt-get install slurmd slurm-client -y` を実行し、パッケージをインストール
- `sudo vi /etc/tmpfiles.d/slurm.conf` を実行し、以下の1行を追加

```sh
d /run/slurm 0770 root slurm -
```

- 以下のコマンドを実行し、`node01` で作成した設定を反映し認証機能を有効化

```bash
sudo cp /clusterfs/munge.key /etc/munge/munge.key
sudo cp /clusterfs/slurm.conf /etc/slurm-llnl/slurm.conf
sudo cp /clusterfs/cgroup* /etc/slurm-llnl

sudo mkdir -p /run/slurm
sudo mkdir -p /var/lib/slurm-llnl
sudo mkdir -p /var/lib/slurm-llnl/spool
sudo mkdir -p /var/log/slurm-llnl
sudo chown -R root:slurm /run/slurm
sudo chown -R slurm:slurm /var/lib/slurm-llnl
sudo chown -R slurm:slurm /var/log/slurm-llnl

sudo systemctl enable munge
sudo systemctl start munge
```

- `ssh node01 munge -n | unmunge` を実行し動作を確認

`node03` の場合：

```bash
pi@comp0X:~ $ ssh node01 munge -n | unmunge
The authenticity of host 'comp01 (10.0.0.11)' can't be established.
ECDSA key fingerprint is SHA256:ShUSjehA+I6ZDGqM9NBcfTIybeq6Yk+d+pGoRumgeTk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'comp01,10.0.0.11' (ECDSA) to the list of known hosts.
pi@comp01's password:
STATUS:           Success (0)
ENCODE_HOST:      node03 (127.0.1.1)
ENCODE_TIME:      2021-10-04 03:18:25 +0100 (1633313905)
DECODE_TIME:      2021-10-04 03:18:25 +0100 (1633313905)
TTL:              300
CIPHER:           aes128 (4)
MAC:              sha256 (5)
ZIP:              none (0)
UID:              pi (1000)
GID:              pi (1000)
LENGTH:           0
```

- 以下のコマンドを実行し、Slurmクライアントを有効化

```bash
sudo systemctl enable slurmd
sudo find / -name slurmd.service -print
sudo vi /etc/systemd/system/multi-user.target.wants/slurmd.service

PIDFile=/run/slurm/slurmd.pid

sudo systemctl daemon-reload
sudo systemctl start slurmd
sudo systemctl status slurmd
```

- `sudo reboot` を実行して再起動、再ログイン

## NIS クライアントのインストール

- 以下のコマンドを実行し、NISをインストール

```bash
sudo apt-get install nis -y
pugaku
```

- `sudo vi /etc/yp.conf` を実行し、以下の1行を追加

```sh
ypserver node01
```

- `sudo vi /etc/defaultdomain` を実行し、次の1行を追加、NISドメインを設定

```bash
pugaku
```

- `sudo vi /etc/nsswitch.conf` を実行し、以下のように編集して参照順番を設定

```sh
passwd:         nis files
group:          nis files
shadow:         nis files
gshadow:        nis files

hosts:          nis files mdns4_minimal [NOTFOUND=return] dns
networks:       nis files
```

- 以下のコマンドを実行し、NIS クライアントを再起動

```bash
sudo systemctl enable rpcbind
sudo systemctl restart rpcbind
```

> **注意**
> ここまでの手順をすべての計算ノードに対して実行する。

## Slurm のテスト

- `node01` にログインして、`sinfo` を実行する

```bash
pi@node01:~ $ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
debug        up   infinite      1   idle node01
comp*        up   infinite      3   idle node[02-04]
i@node01:~ $ srun --nodes=3 hostname
srun: Required node not available (down, drained or reserved)
srun: job 2 queued and waiting for resources
^Csrun: Job allocation 2 has been revoked
srun: Force Terminated job 2
pi@node01:~ $ sudo scontrol update NodeName=node0[2-4] state=RESUME
pi@node01:~ $ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
debug        up   infinite      1   idle node01
comp*        up   infinite      3   idle node[02-04]
pi@node01:~ $ srun --nodes=3 hostname
node02
node03
node04
pi@node01:~ $
```

> **注意**
>
> `sinfo`しても計算ノードのSTATUSが`down`のままになる場合は、以下のいずれかをためしてください。
>
> 1. 該当計算ノードにて`sudo systemctl restart slurmd` を実行
> 2. ログインノードにて`sudo scontrol update nodename=node0[2-4] state=resume` を実行
> 3. ログインノードにて `sudo scontrol reconfigure` を実行

上記以外のSlurm 機能を試したい人は [チートシート](https://slurm.schedmd.com/pdfs/summary.pdf) を参照のこと。

## 前のステップ

- [ログインノードのインストール手順](./login_node.md)
