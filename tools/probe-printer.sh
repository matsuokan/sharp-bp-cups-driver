#!/bin/bash
# ==========================================================
# probe-printer.sh — プリンターIPP属性調査ツール
# 使い方: bash tools/probe-printer.sh [IP] [PORT]
# ==========================================================

PRINTER_IP="${1:?使い方: $0 [IPアドレス]}"
PORT="${2:-631}"
URI="ipp://${PRINTER_IP}:${PORT}/ipp/lp"

echo "================================================"
echo "  Printer IPP Probe Tool"
echo "  URI: $URI"
echo "================================================"
echo ""

# 接続確認
echo "[1/3] 接続確認中..."
if ! ping -c1 -W2 "$PRINTER_IP" > /dev/null 2>&1; then
    echo "❌ プリンターに到達できません: $PRINTER_IP"
    exit 1
fi
echo "✅ 到達OK"
echo ""

# IPP属性を取得
echo "[2/3] IPP属性を取得中..."
ATTRS=$(ipptool -tv "$URI" /usr/share/cups/ipptool/get-printer-attributes.test 2>&1)

# 重要な属性を表示
echo ""
echo "=== 🔑 重要な属性 ==="
echo ""
echo "--- フォーマット関連 ---"
echo "$ATTRS" | grep -E "document-format" | sed 's/^[[:space:]]*/  /'
echo ""
echo "--- URF/AirPrint対応 ---"
echo "$ATTRS" | grep -E "urf-supported|airprint" | sed 's/^[[:space:]]*/  /'
echo ""
echo "--- PDF対応 ---"
echo "$ATTRS" | grep -E "pdf-versions|pdl-override" | sed 's/^[[:space:]]*/  /'
echo ""
echo "--- ジョブ属性 ---"
echo "$ATTRS" | grep -E "job-creation-attributes" | sed 's/^[[:space:]]*/  /'
echo ""

# 判定レポート
echo "[3/3] 対応状況の判定..."
echo ""

URF_OK=false
PDF_OK=false
DOC_FORMAT_IN_JOB=false

echo "$ATTRS" | grep -q "urf-supported" && URF_OK=true
echo "$ATTRS" | grep -q "pdf-versions-supported" && PDF_OK=true
echo "$ATTRS" | grep "job-creation-attributes-supported" | grep -q "document-format" && DOC_FORMAT_IN_JOB=true

echo "=== 🎯 判定結果 ==="
if $URF_OK; then
    echo "  ✅ URF対応: このドライバーで印刷可能"
else
    echo "  ⚠️  URF未確認: 別のアプローチが必要な可能性"
fi

if $PDF_OK; then
    echo "  ✅ PDF対応を宣言 (注: 実際には印刷できない場合あり)"
fi

if $DOC_FORMAT_IN_JOB; then
    echo "  ✅ document-format属性を受け付ける"
else
    echo "  ⚠️  document-format属性を送らない方が安全"
fi

echo ""
echo "=== 📋 device-info.md 用テンプレート ==="
MODEL=$(echo "$ATTRS" | grep "printer-name\|model-name" | head -1 | sed 's/.*= //')
URF_VAL=$(echo "$ATTRS" | grep "urf-supported" | sed 's/.*= //')
FMT_DEF=$(echo "$ATTRS" | grep "document-format-default" | sed 's/.*= //')
PDL=$(echo "$ATTRS" | grep "pdl-override-supported" | sed 's/.*= //')

cat << EOF
# Device Info
- 調査日: $(date +%Y-%m-%d)
- IP: $PRINTER_IP
- document-format-default: ${FMT_DEF:-未確認}
- urf-supported: ${URF_VAL:-未確認}
- pdl-override-supported: ${PDL:-未確認}
- 動作確認: ❌ 未テスト
EOF
