# sharp-bp-cups-driver

SHARP BP シリーズプリンター（BP-40C26 等）の Linux / CUPS 用ドライバーです。

Debian / Ubuntu で **LibreOffice・ブラウザ・コマンドラインから印刷できます。**

---

## なぜこのドライバーが必要か

SHARP BP シリーズは IPP で「PDF 対応」と返答しますが、**実際には URF（Apple AirPrint 用ラスター形式）でないと印刷されません。** このドライバーは PDF を URF に変換してから送信することで問題を解決しています。

```
アプリ → PDF → [pdftourf] URF変換 → [sharpipp] IPP送信 → SHARP プリンター ✅
```

---

## 対応機種

| 機種 | 確認済み |
|---|---|
| SHARP BP-40C26 | ✅ |
| SHARP BP シリーズ（他機種） | 未確認（おそらく動作） |

---

## 必要環境

- **OS**: Debian 12+ / Ubuntu 22.04+
- **パッケージ**: `cups`, `ghostscript`, `ipptool`（インストールスクリプトで自動インストール）
- **接続**: WiFi / LAN 経由（プリンターの IP アドレスが必要）

---

## インストール

```bash
git clone https://github.com/matsuokan/sharp-bp-cups-driver
cd sharp-bp-cups-driver
sudo bash install.sh 192.168.X.X   # プリンターの IP アドレスを指定
```

### テスト印刷

```bash
lp -d SHARP-BP40C26 /usr/share/cups/data/default-testpage.pdf
```

---

## 使い方

インストール後は通常通り印刷できます。

- **LibreOffice**: ファイル → 印刷 → `SHARP-BP40C26` を選択
- **ブラウザ**: 印刷 → `SHARP-BP40C26` を選択
- **コマンドライン**: `lp -d SHARP-BP40C26 ファイル名.pdf`

---

## ファイル構成

```
sharp-bp-cups-driver/
├── install.sh                  # インストールスクリプト
├── driver/
│   ├── SHARP-BP40C26.ppd       # プリンター定義ファイル
│   ├── filter/
│   │   └── pdftourf            # PDF→URF変換フィルター（Ghostscript使用）
│   └── backend/
│       └── sharpipp            # IPPバックエンド（ipptool使用）
└── docs/
    ├── how-it-works.md         # 技術的な説明
    └── troubleshooting.md      # トラブルシューティング
```

---

## 技術的な詳細

[docs/how-it-works.md](docs/how-it-works.md) を参照。

---

## トラブルシューティング

[docs/troubleshooting.md](docs/troubleshooting.md) を参照。

---

## ライセンス

MIT License

---

## 貢献

Issue・PR 歓迎です。他の SHARP BP シリーズ機種での動作報告もお待ちしています。
