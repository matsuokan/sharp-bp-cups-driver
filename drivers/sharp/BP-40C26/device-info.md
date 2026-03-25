# SHARP BP-40C26 — Device Info

## IPP属性（実機調査済み）

| 属性 | 値 |
|---|---|
| 調査日 | 2026-03-24 |
| IP | 192.168.50.26 |
| `document-format-default` | `image/urf` |
| `document-format-preferred` | `application/pdf` |
| `pdf-versions-supported` | `iso-32000-1_2008` |
| `urf-supported` | `V1.5,W8,SRGB24,RS600-1200,IS4-20-21-22-23,OB1-7-10,FN3,CP255,DM1,MT1,PQ3-4-5` |
| `pdl-override-supported` | `guaranteed` |
| `job-creation-attributes-supported` | `document-format` を**含まない** |
| `ipp-versions-supported` | `1.0,1.1,2.0` |

## 重要な発見

- PDFを送ると `job-completed-successfully` を返すが**実際には印刷されない**
- URF形式で送ると正常に印刷される
- `document-format` 属性をIPPリクエストに含めるとエラーになる
- `pdl-override-supported=guaranteed` により URF を自動検出する

## 動作確認

- ✅ URF（urfrgb@600dpi）での印刷
- ✅ LibreOffice Calc からの GUI 印刷
- ✅ ブラウザからの印刷
- ✅ `lp` コマンドからの印刷
- ❌ PDF直接送信（受け取るが印刷しない）
