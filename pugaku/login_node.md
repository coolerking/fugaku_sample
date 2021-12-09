# 貧岳ログインノード(node01)インストール手順

## 必要なもの

- Raspberry Pi本体×1
- SDカード×1
- 電源用USBケーブルとACアダプタ×1
- 有線LANケーブル×1
- ネットワークハブ（貧岳全体で1つ)
- インターネット接続可能なWiFiルータ（貧岳全体で1つ)

## OS起動

- ログインノード用Raspberry PiにLANケーブルを接続しネットワークハブに接続
- SDカードをSDCardフォーマッタなどでフォーマット
- [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/) から最新版Raspberry Pi OS Lite イメージをダウンロード＆展開
- Win32DiskImagerなどでSDカードへイメージ書き込み
- SDカードルートディレクトリ上に空のファイル `ssh` を作成
- SDカードルートディレクトリ上に `wpa_supplicant.conf` を作成し以下のようにWiFiルータ設定を書き込み保存

```text
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
  - hostnameに `node01` を設定
  - `pi` ユーザのパスワードを設定（全ノード同じにしておくと楽）
  - 使用するインターフェイスを有効化（Camera、I2C、Wireress GPIOなど)
  - OpenGLを使用する場合などは GL>Fake GL
- `raspi-config` 終了時に再起動を選択し、再起動
- `sudo apt-get install -y build-essential python3 python3-dev python3-pip python3-virtualenv python3-numpy python3-picamera python3-pandas python3-rpi.gpio i2c-tools avahi-utils joystick libopenjp2-7-dev libtiff5-dev gfortran libatlas-base-dev libopenblas-dev libhdf5-serial-dev libgeos-dev git ntp libilmbase-dev libopenexr-dev libgstreamer1.0-dev libjasper-dev libwebp-dev libatlas-base-dev libavcodec-dev libavformat-dev libswscale-dev libqtgui4 libqt4-test ntpdate nfs-kernel-server mailutils`
- `sudo vi /etc/hosts` を実行し以下の行を追加

```text
## pugaku
10.0.0.1 node01
10.0.0.2 node02
10.0.0.3 node03
10.0.0.4 node04
```

- `sudo vi /etc/dhcpcd.conf` を実行し以下の行を挿入

```text
interface eth0
static ip_address=10.0.0.1/8
```

- 以下のコマンドを実行し、作業用共有ディレクトリを作成

```bash
sudo mkdir /clusterfs
sudo chown nobody.nogroup -R /clusterfs
sudo chmod 777 -R /clusterfs
```

- `sudo vi /etc/exports` を実行し `/home` と `/clusterfs` をNFSエクスポート設定を実施

```text
/home           10.0.0.0/8(rw,sync,no_root_squash,no_subtree_check)
/clusterfs      10.0.0.0/8(rw,sync,no_root_squash,no_subtree_check)
```

- `sudo exportfs -a` を実行し、NFS可能にする
- `sudo reboot`

## SLURM マスタセットアップ

- `sudo apt-get install slurm-wlm sview -y`
- `sudo vi /etc/tmpfiles.d/slurm.conf` を実行し、以下の行を追加し保存

```text
d /run/slurm 0770 root slurm -
```

- 以下のコマンドを実行し、デフォルトSLURM設定ファイルを取得

```bash
cd /etc/slurm-llnl
sudo cp /usr/share/doc/slurm-client/examples/slurm.conf.simple.gz .
sudo gzip -d slurm.conf.simple.gz
sudo mv slurm.conf.simple slurm.conf
```

- `sudo vi /etc/slurm-llnl/slurm.conf` を実行し、設定を追加もしくは変更し保存

```text
:
SlurmctldHost=node01(10.0.0.1)
:
CluserName=pugaku
:
SlurmctldPidFile=/var/run/slurm/slurmctld.pid
:
SlurmdPidFile=/var/run/slurm/slurmd.pid
:
NodeName=node01 NodeAddr=10.0.0.1 CPUs=4 State=UNKNOWN
NodeName=node02 NodeAddr=10.0.0.2 CPUs=4 State=UNKNOWN
NodeName=node03 NodeAddr=10.0.0.3 CPUs=4 State=UNKNOWN
NodeName=node04 NodeAddr=10.0.0.4 CPUs=4 State=UNKNOWN
PartitionName=debug Nodes=node01 MaxTime=INFINITE State=UP
PartitionName=comp Nodes=node0[2-4] Default=YES MaxTime=INFINITE State=UP
```

- `sudo vi /etc/slurm-llnl/cgroup.conf` を実行し、以下の行を追加して保存

```text
CgroupMountpoint="/sys/fs/cgroup"
CgroupAutomount=yes
CgroupReleaseAgentDir="/etc/slurm-llnl/cgroup"
AllowedDevicesFile="/etc/slurm-llnl/cgroup_allowed_devices_file.conf"
ConstrainCores=no
TaskAffinity=no
ConstrainRAMSpace=yes
ConstrainSwapSpace=no
ConstrainDevices=no
AllowedRamSpace=100
AllowedSwapSpace=0
MaxRAMPercent=100
MaxSwapPercent=100
MinRAMSpace=30
```

- `sudo vi /etc/slurm-llnl/cgroup_allowed_devices_file.conf` を実行し、以下の行を追加して保存

```text
/dev/null
/dev/urandom
/dev/zero
/dev/sda*
/dev/cpu/*/*
/dev/pts/*
/clusterfs*
/home*
```

- 以下のコマンドを実行し、計算ノード配布用SLURM設定ファイル群をコピー

```bash
sudo cp slurm.conf cgroup.conf cgroup_allowed_devices_file.conf /clusterfs
sudo cp /etc/munge/munge.key /clusterfs

sudo mkdir -p /run/slurm
sudo mkdir -p /var/lib/slurm-llnl
sudo mkdir -p /var/lib/slurm-llnl/spool
sudo mkdir -p /var/log/slurm-llnl
sudo chown -R root:slurm /run/slurm
sudo chown -R slurm:slurm /var/lib/slurm-llnl
sudo chown -R slurm:slurm /var/log/slurm-llnl
```

- 以下のコマンドを実行し、munge/slurmを起動

```bash
sudo systemctl enable munge
sudo systemctl start munge

sudo systemctl enable slurmd
```

- `sudo find / -name slurmd.service -print` を実行し、表示されるすべてのファイルのpidファイル書き込み先設定を `/run/slurm` に変更
  - たとえば `sudo vi /etc/systemd/system/multi-user.target.wants/slurmd.service`
- pidファイルパス変更後、以下のコマンドを実行

```bash
sudo systemctl daemon-reload
sudo systemctl restart slurmd
sudo systemctl status slurmd
```

- 以下のコマンドを実行して `slurmctld` に対してもPIDファイルパスを `/run/slurm` に変更

```bash
sudo systemctl enable slurmctld
sudo find / -name slurmctld.service -print
sudo vi /etc/systemd/system/multi-user.target.wants/slurmctld.service

/run/slurm に変更

sudo systemctl daemon-reload
sudo systemctl restart slurmctld
sudo systemctl status slurmctld
```

- 一旦 `sudo reboot`

### NIS セットアップ

- `sudo apt-get install nis -y`
  - ドメイン名には `pugaku` を指定
- `sudo vi /etc/ypserv.securenets` を実行し、コメントアウト及び追加し保存(XXはWiFiルータの使用するセグメントに適宜変更）

```text
#0.0.0.0        0.0.0.0
255.0.0.0       10.0.0.0
255.255.255.0   192.168.XX.0
```

- `sudo vi /etc/default/nis` を実行し、以下の行を変更し保存

```text
:
NISSERVER=master
:
NISCLIENT=false
```

- `sudo /usr/lib/yp/ypinit -m`
  - `Ctrl`+`D`
  - `y`
- `sudo systemctl restart rpcbind`

## pdsh セットアップ

- `sudo apt-get install pdsh -y`
- `sudo echo "ssh" > /etc/pdsh/rcmd_default`
- 以下のコマンドを実行して`pi`ユーザの公開鍵を作成

```bash
cd
ssh-keygen -t rsa

Enter
パスフレーズ(2回入力)

cd .ssh
cat id_rsa.pub >> authorized_keys
chmod 600 /clusterfs/authorized_keys
cd
mkdir -p ~/.dsh/group
```

- `vi ~/.dsh/group/comp` を実行し、以下の行を追加して保存

```text
10.0.0.2
10.0.0.3
10.0.0.4
```

- `pdsh -g comp hostname` を実行してテスト

## 次のステップ

以下の手順をすべての計算ノードに対して実施。

- [計算ノードのインストール手順](./comp_node.md)
