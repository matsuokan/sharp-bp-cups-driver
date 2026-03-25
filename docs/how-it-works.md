# 仕組みの説明

## 問題: SHARP BP は PDF を「受け取るが印刷しない」

SHARP BP シリーズは IPP の `get-printer-attributes` で以下を返します：

```
document-format-default = image/urf   ← デフォルトは URF
pdf-versions-supported = iso-32000-1_2008  ← PDF 対応と言っている
```

しかし実際に PDF を IPP 経由で送っても、プリンターは：
-「`job-completed-successfully`」と返す（成功のふり）
- **物理的に印刷しない**

これは SHARP のファームウェアのバグと思われます。iPhone の AirPrint が動作するのは、Apple が **URF 形式** で送信しているためです。

---

## 解決策: PDF → URF 変換

```
PDF → Ghostscript (urfrgb @600dpi) → URF → ipptool (document-format 未指定) → プリンター
```

### カスタムコンポーネント

#### `driver/filter/pdftourf`
CUPS フィルタースクリプト。Ghostscript の `urfrgb` デバイスを使って PDF を URF に変換します。

```bash
gs -sDEVICE=urfrgb -r600 -sOutputFile=output.urf input.pdf
```

#### `driver/backend/sharpipp`
CUPS バックエンドスクリプト。`ipptool` を使って URF データをプリンターに送信します。

**重要**: `document-format` 属性を IPP リクエストに含めない。  
このプリンターは `job-creation-attributes-supported` に `document-format` を含めておらず、指定すると `client-error-attributes-or-values-not-supported` が返る。  
代わりに `pdl-override-supported = guaranteed` によりプリンターが URF を自動検出する。

#### `driver/SHARP-BP40C26.ppd`
CUPS PPD ファイル。`cupsFilter2` で PDF → URF 変換フィルターを指定。

---

## デバッグ

```bash
# sharpipp のデバッグログを確認
sudo cat /tmp/sharpipp-debug.log

# CUPS のエラーログを確認
sudo grep "Job XX" /var/log/cups/error_log | grep -v "^D"
```
