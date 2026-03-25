# トラブルシューティング

## 印刷しても紙が出ない

### 確認1: CUPS のジョブログ
```bash
sudo grep "Job" /var/log/cups/error_log | grep -v "^D" | tail -10
```
`Job completed` と表示されれば CUPS 側は正常。

### 確認2: sharpipp デバッグログ
```bash
sudo cat /tmp/sharpipp-debug.log | tail -30
```

`ipptool: Unexpected token` が表示される場合 → ファイル名に特殊文字（PI, IN 等）が含まれています。最新の sharpipp では自動でエスケープされます。

### 確認3: URF 変換テスト
```bash
# 手動で URF に変換してみる
gs -q -dNOPAUSE -dBATCH -dSAFER \
   -sDEVICE=urfrgb -r600 \
   -sOutputFile=/tmp/test.urf \
   /usr/share/cups/data/default-testpage.pdf
ls -la /tmp/test.urf  # ファイルが生成されれば OK
```

---

## CUPS にプリンターが表示されない

```bash
# CUPS を再起動
sudo systemctl restart cups

# プリンターを再登録
sudo bash install.sh 192.168.X.X
```

---

## `ipptool` コマンドが見つからない

```bash
sudo apt-get install ipptool
```

---

## Ghostscript に `urfrgb` デバイスがない

Ghostscript 9.56 以降が必要です。

```bash
gs --version  # 9.56 以上を確認
sudo apt-get install --only-upgrade ghostscript
```

---

## よくある質問

**Q: SHARP の Windows ドライバーをインストールすれば動かないの？**  
A: Windows ドライバーは Linux では使えません。このドライバーは CUPS + Ghostscript のみで動作します。

**Q: 他の SHARP 機種でも動く？**  
A: `urf-supported` 属性を持つ SHARP IPP 対応機種なら動作する可能性があります。動作確認済みの場合は Issue で報告してください。
