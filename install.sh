#!/bin/bash
# ============================================================
# SHARP BP シリーズ CUPS ドライバー インストールスクリプト
# 対応: Debian 12+ / Ubuntu 22.04+
# 使い方: sudo bash install.sh [プリンターのIPアドレス]
# ============================================================

set -e

PRINTER_IP="${1:-192.168.50.26}"
PRINTER_NAME="SHARP-BP40C26"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "  SHARP BP CUPS ドライバー インストーラー"
echo "  プリンター IP: $PRINTER_IP"
echo "================================================"
echo ""

# root 確認
if [ "$(id -u)" -ne 0 ]; then
    echo "エラー: sudo で実行してください"
    echo "  sudo bash $0 $PRINTER_IP"
    exit 1
fi

# 依存パッケージのインストール
echo "[1/4] 必要なパッケージをインストール中..."
apt-get update -qq
apt-get install -y cups cups-filters ghostscript ipptool avahi-daemon

# サービスを起動
echo "[2/4] サービスを起動中..."
systemctl enable --now cups avahi-daemon
sleep 2

# フィルター・バックエンドをインストール
echo "[3/4] ドライバーファイルをインストール中..."
install -m 755 "$SCRIPT_DIR/driver/filter/pdftourf"   /usr/lib/cups/filter/pdftourf
install -m 700 "$SCRIPT_DIR/driver/backend/sharpipp"  /usr/lib/cups/backend/sharpipp

# 既存キューを削除して再作成
lpadmin -x "$PRINTER_NAME" 2>/dev/null || true

echo "[4/4] プリンターキューを設定中..."
lpadmin -p "$PRINTER_NAME" \
    -v "sharpipp://${PRINTER_IP}:631/ipp/lp" \
    -P "$SCRIPT_DIR/driver/SHARP-BP40C26.ppd" \
    -D "SHARP BP-40C26" \
    -E

# デフォルトプリンターに設定
lpadmin -d "$PRINTER_NAME"

echo ""
echo "================================================"
echo "  インストール完了！"
echo "  プリンター名: $PRINTER_NAME"
echo ""
echo "  テスト印刷:"
echo "  lp -d $PRINTER_NAME /usr/share/cups/data/default-testpage.pdf"
echo "================================================"
