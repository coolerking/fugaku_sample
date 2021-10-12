# 貧岳: Pugaku (Pi Cluster for Proletariat)

![Pugaku: Pi Cluster for Proletariat](./images/pugaku.png)

貧学 (pugaku: Pi Cluster for Proletariat) は、富岳上でテスト実行する前に事前に開発・テストするためのRaspberry Pi クラスタ環境です。

## 構成

![pugaku outlook](./images/pugaku_outlook.jpg)

- ログインノード/NFSサーバ/NISマスタ/Slurmマスタ/NTPクライアント
  - Raspberry Pi 4/2GB x 1
  - 32GB SD-Card x 1
  - AC アダプタ x 1
  - LAN ケーブル x 1

- 計算ノード/NFSクライアント/NISクライアント/Slurmワーカ/NTPクライアント
  - Raspberry Pi 3B+/1GB x 3
  - 32GB SD-Card x 3
  - AC アダプタ x 3
  - LAN ケーブル x 3

- ネットワーク
  - 運用系(10.0.0.0/8)
    - 5ポートHUBを使った有線によるLAN接続
    - NFS/NIS/Slurm
  - サービス系(192.168.XX.0/24)
    - インターネットに接続可能なWiFiルータとの接続
    - apt/pip/ssh/scp/ntp

## セットアップ

- [ログインノードセットアップ手順](./login_node.md)
- [計算ノードセットアップ](./comp_node.md)
