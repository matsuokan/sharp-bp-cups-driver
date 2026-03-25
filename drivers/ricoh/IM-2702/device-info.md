# RICOH IM 2702 — Device Info

## ステータス: ⚠️ 未テスト（実機での動作確認が必要）

## 既知の IPP エンドポイント
- `ipp://[IP]:631/printer`

## 調査手順
```bash
bash tools/probe-printer.sh [プリンターのIPアドレス]
```

## 属性（調査後に記入）

| 属性 | 値 |
|---|---|
| 調査日 | 未調査 |
| `document-format-default` | — |
| `urf-supported` | — |
| `pdl-override-supported` | — |
| 動作確認 | ❌ 未テスト |

## 備考
RICOHのIPPエンドポイントは機種によって/printer または /ipp/print の場合がある

## 動作確認済みの場合はPRを送ってください
→ https://github.com/matsuokan/sharp-bp-cups-driver
