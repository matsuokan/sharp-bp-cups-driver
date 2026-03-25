# 複合機 Linux ドライバー 対応ロードマップ

## 基本方針

### なぜ Linux ドライバーが必要か？

1. **Windows 10 サポート終了（2025年10月）** により、古い複合機の Windows ドライバーが使えなくなる
2. Windows 11 非対応の複合機でも Linux なら引き続き使用可能
3. 企業のセキュリティ要件で Linux 移行が進んでいる

### 技術的アプローチ（SHARP BP で実証済み）

```
アプリ → PDF → [pdftourf] URF変換 → [sharpipp] IPP送信 → プリンター ✅
```

ほとんどの現代の複合機は **IPP + URF（AirPrint）** に対応しているため、
同じアーキテクチャで複数メーカーに対応できる。

---

## 対応優先度マップ

### 🥇 Phase 1（優先対応）— シェア上位 + IPP/AirPrint対応

| 優先度 | メーカー | 世界シェア | 主要対象機種（Windows非対応モデル） |
|:---:|---|:---:|---|
| ⭐⭐⭐ | **SHARP** | 5位 | BP-40C26 ✅、MX-3070、MX-4070 |
| ⭐⭐⭐ | **RICOH** | 2位 | IM 2702、MP 2555、MP C3004 |
| ⭐⭐⭐ | **Canon** | 1位 | iR-ADV C3826、imageRUNNER 2625 |
| ⭐⭐ | **Konica Minolta** | 3位 | bizhub C3320i、C458 |

### 🥈 Phase 2（順次対応）

| 優先度 | メーカー | 主要対象機種 |
|:---:|---|---|
| ⭐⭐ | **Kyocera** | TASKalfa 2553ci、ECOSYS M6635cidn |
| ⭐⭐ | **Fujifilm** | Apeos C3571、DocuCentre-VIC2271 |
| ⭐ | **Toshiba Tec** | e-STUDIO 2518A、4518A |

---

## 技術調査チェックリスト（機種追加時）

各機種で確認する情報：

```bash
# IPP属性を取得（最重要）
ipptool -tv ipp://[IP]:631/ipp/lp get-printer-attributes.test | grep -E \
  "document-format|urf-supported|pdl-override|pdf-versions"
```

| 確認項目 | 確認コマンド/方法 |
|---|---|
| **document-format-default** | URF か PDF か確認 |
| **urf-supported** | V1.x,RS600 等の値を確認 |
| **pdf-versions-supported** | PDFが本当に動くか実際に検証 |
| **pdl-override-supported** | `guaranteed` なら自動検出可能 |
| **job-creation-attributes-supported** | `document-format`が含まれるか |

---

## リポジトリ構成（将来版）

```
jpn-mfp-cups-driver/          ← 現在
ricoh-cups-driver/             ← 次
canon-cups-driver/             ← 次々

# または統合版
universal-jpn-cups-driver/
├── drivers/
│   ├── sharp/
│   ├── ricoh/
│   ├── canon/
│   └── konica/
├── core/
│   ├── filter/pdftourf       ← 共通フィルター
│   └── backend/ippbackend    ← 共通バックエンド
└── install.sh                ← メーカー選択式インストーラー
```

---

## Windows 10 サポート終了対策

### 複合機メーカーのWindows 10ドライバー提供状況

Windows 10 サポート終了（2025年10月）後も使い続けるための選択肢：

| 選択肢 | コスト | 難易度 |
|---|:---:|:---:|
| Windows 11 対応機に買い替え | 高 | 低 |
| **Linux + このドライバー** | **無料** | **低** |
| Windows Server 経由で共有 | 中 | 中 |

---

## 次のステップ

1. **RICOH IM シリーズのIPP属性を調査**（GitHubで機種別 Issue を作成）
2. **SHARP MX シリーズ**（BP より古い世代）への対応確認
3. AirPrint 非対応の旧機種向けに **PCL 変換フィルター** を検討

---

*最終更新: 2026-03-25 | Developed by MetaDataLab Inc.*
