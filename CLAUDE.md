# CLAUDE.md — AI開発者向けプロジェクトガイド

## プロジェクト概要

**jpn-mfp-cups-driver** は、日本の複合機（SHARP・RICOH・Canon等）を
Linux / CUPS で使えるようにするドライバー集です。

### コアとなる技術的インサイト

> ⚠️ **重要**: 多くの日本製複合機は IPP で「PDF対応」と返答するが、
> 実際には **URF (Apple AirPrint Raster)** 形式でないと印刷されない。
> iPhone の AirPrint が動作する理由もこれ。

#### 解決済みアーキテクチャ（SHARP BP-40C26で実証済み）:

```
PDF → [pdftourf] gs -sDEVICE=urfrgb → URF → [sharpipp] ipptool → プリンター ✅
```

---

## リポジトリ構造

```
jpn-mfp-cups-driver/
├── CLAUDE.md               ← このファイル（AI開発者向けガイド）
├── README.md               ← エンドユーザー向け
├── install.sh              ← インストーラー（メーカー・モデル選択式）
│
├── core/                   ← 全機種共通コンポーネント
│   ├── filter/
│   │   └── pdftourf        ← PDF→URF変換フィルター（Ghostscript使用）
│   └── backend/
│       └── sharpipp        ← IPPバックエンド（ipptool使用）
│
├── drivers/                ← メーカー別・機種別PPD
│   ├── sharp/
│   │   └── BP-40C26/
│   │       ├── SHARP-BP40C26.ppd
│   │       └── device-info.md  ← IPP属性・動作確認記録
│   ├── ricoh/              ← 未対応（調査中）
│   └── canon/              ← 未対応（調査中）
│
├── tools/
│   └── probe-printer.sh    ← プリンターIPP属性調査ツール
│
└── docs/
    ├── how-it-works.md     ← 技術解説
    ├── troubleshooting.md  ← トラブルシューティング
    └── roadmap.md          ← 対応計画
```

---

## 新機種追加の手順

### Step 1: IPP属性を調査

```bash
bash tools/probe-printer.sh 192.168.X.X
```

確認すべき重要な属性:

| 属性 | 意味 | 期待値 |
|---|---|---|
| `document-format-default` | デフォルト送信形式 | `image/urf` ならURF対応 |
| `urf-supported` | URFの詳細対応 | `RS600` = 600dpi URF対応 |
| `pdl-override-supported` | 形式自動検出 | `guaranteed` = 自動検出OK |
| `job-creation-attributes-supported` | `document-format`を受け付けるか | 含まれない場合は属性を送らない |

### Step 2: 実際にURFを送って確認

```bash
# テストURFを生成して直接送信
gs -q -dNOPAUSE -dBATCH -sDEVICE=urfrgb -r600 \
   -sOutputFile=/tmp/test.urf /usr/share/cups/data/default-testpage.pdf

cat > /tmp/test.ipptest << EOF
{ NAME "URF Test" OPERATION Print-Job
  GROUP operation-attributes-tag
  ATTR charset attributes-charset utf-8
  ATTR language attributes-natural-language en
  ATTR uri printer-uri ipp://[IP]:631/ipp/lp
  ATTR name requesting-user-name test
  FILE /tmp/test.urf
  STATUS successful-ok }
EOF

ipptool -tv ipp://[IP]:631/ipp/lp /tmp/test.ipptest
```

### Step 3: PPDを作成

`drivers/[メーカー]/[機種]/` に PPD を作成。`core/filter/pdftourf` を参照。

### Step 4: device-info.md を記録

```markdown
# SHARP MX-XXXX — Device Info
- IP属性調査日: YYYY-MM-DD
- document-format-default: image/urf
- urf-supported: V1.5,RS600...
- 動作確認: ✅/❌
```

---

## コアコンポーネントの説明

### `core/filter/pdftourf`

CUPS フィルター。引数: `job-id user title copies options [filename]`

```bash
gs -sDEVICE=urfrgb -r600 -sOutputFile=OUTPUT INPUT
```

### `core/backend/sharpipp`

CUPS バックエンド。`DEVICE_URI=sharpipp://IP:PORT/PATH` を `ipp://` に変換。

**重要**: `document-format` 属性を**送らない**。プリンターが自動検出する。

ジョブ名に特殊文字（`PI`, `IN` 等はipptoolの予約語）が含まれると失敗する。
→ `SAFE_TITLE=$(echo "$TITLE" | tr -cd 'a-zA-Z0-9._- ')` でサニタイズ済み。

---

## よくある問題

| 症状 | 原因 | 解決 |
|---|---|---|
| `job-completed-successfully` だが紙が出ない | PDFを送っている | URF形式で送信 |
| `040D error` | PDFを送っているがプリンターが拒否 | URF形式で送信 |
| `Unexpected token PI` | ジョブ名に"PI"を含む | SAFE_TITLEでサニタイズ |
| `ipptool not found` | パッケージ名違い | `cups-ipp-utils` をインストール |

---

## 開発環境セットアップ

```bash
# 依存パッケージ
sudo apt-get install cups cups-filters ghostscript cups-ipp-utils

# デバッグログ確認
sudo cat /tmp/sharpipp-debug.log

# CUPSログ確認
sudo grep "Job" /var/log/cups/error_log | grep -v "^D" | tail -20

# 手動バックエンドテスト
sudo -E bash -c 'DEVICE_URI="sharpipp://IP:631/ipp/lp" \
  bash -x /usr/lib/cups/backend/sharpipp 99 user "test" 1 "" /tmp/test.pdf'
```

---

*Developed by MetaDataLab Inc. | MIT License*
