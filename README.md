# jpn-mfp-cups-driver

SHARP BP シリーズを含む **日本製複合機の Linux / CUPS 用ドライバー集**です。

Debian / Ubuntu で LibreOffice・ブラウザ・コマンドラインから印刷できます。

---

## なぜこのドライバーが必要か

多くの日本製複合機は IPP で「PDF対応」と返答しますが、**実際には URF（Apple AirPrint 用ラスター形式）でないと印刷されません。** このドライバーは PDF を URF に変換して送信します。

```
アプリ → PDF → [pdftourf] URF変換 → [sharpipp] IPP送信 → 複合機 ✅
```

---

## インストール

```bash
git clone https://github.com/matsuokan/jpn-mfp-cups-driver
cd jpn-mfp-cups-driver
sudo bash install.sh 192.168.X.X          # 対話式（機種を選択）
sudo bash install.sh 192.168.X.X sharp BP-40C26  # 直接指定
```

---

## 対応機種

| メーカー | 機種 | ステータス | 備考 |
|---|---|:---:|---|
| **SHARP** | BP-40C26 | ✅ 確認済み | LibreOffice/ブラウザ動作確認 |
| **SHARP** | MX-3070 | ⚠️ テンプレート | 実機テスト求む |
| **SHARP** | MX-4070 | ⚠️ テンプレート | 実機テスト求む |
| **RICOH** | IM 2702 | ⚠️ テンプレート | 実機テスト求む |
| **RICOH** | MP C3004 | ⚠️ テンプレート | 実機テスト求む |
| **Canon** | iR-ADV C3826 | ⚠️ テンプレート | 実機テスト求む |
| **Canon** | imageRUNNER 2625 | ⚠️ テンプレート | 実機テスト求む |
| **Konica Minolta** | bizhub C3320i | ⚠️ テンプレート | 実機テスト求む |
| **Konica Minolta** | bizhub C458 | ⚠️ テンプレート | 実機テスト求む |
| **Kyocera** | TASKalfa 2553ci | ⚠️ テンプレート | 実機テスト求む |
| **Kyocera** | ECOSYS M6635cidn | ⚠️ テンプレート | 実機テスト求む |
| **Fujifilm** | Apeos C3571 | ⚠️ テンプレート | 実機テスト求む |
| **Fujifilm** | DocuCentre-VI C2271 | ⚠️ テンプレート | 実機テスト求む |
| **Toshiba** | e-STUDIO 2518A | ⚠️ テンプレート | 実機テスト求む |
| **Toshiba** | e-STUDIO 4518A | ⚠️ テンプレート | 実機テスト求む |

> ⭐ 動作確認済みの方は **Issue** または **PR** で報告してください！

---

## 必要環境

- **OS**: Debian 12+ / Ubuntu 22.04+
- **接続**: WiFi / LAN（プリンターの IP アドレスが必要）
- 依存パッケージはインストーラーが自動インストール

---

## アンインストール

```bash
sudo bash install.sh --uninstall SHARP-BP40C26
```

---

## 新機種の調査ツール

```bash
# プリンターの IPP 属性を調査
bash tools/probe-printer.sh 192.168.X.X
```

---

## 技術詳細・トラブルシューティング

- [仕組みの説明](docs/how-it-works.md)
- [トラブルシューティング](docs/troubleshooting.md)
- [開発ロードマップ](docs/roadmap.md)
- [AI開発者向けガイド](CLAUDE.md)

---

## ライセンス

MIT License — Developed by MetaDataLab Inc.
