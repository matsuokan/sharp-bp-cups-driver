#!/bin/bash
# ============================================================
# SHARP BP シリーズ CUPS ドライバー インストールスクリプト
# 対応: Debian 12+ / Ubuntu 22.04+
# 使い方: sudo bash install.sh [プリンターのIPアドレス]
# ============================================================

set -e

VERSION="1.0.0"
PRINTER_IP="${1:-192.168.50.26}"
PRINTER_NAME="SHARP-BP40C26"
PPD_FILE="SHARP-BP40C26.ppd"
FILTER_NAME="pdftourf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "  Sharp BP Series CUPS Driver"
echo "  Version: $VERSION"
echo "================================================"
echo ""

# root 確認
if [ "$(id -u)" -ne 0 ]; then
    echo "エラー: sudo で実行してください"
    echo "  sudo bash $0 $PRINTER_IP"
    exit 1
fi

# アンインストール
if [ "$1" = "--uninstall" ]; then
    echo "アンインストール中..."
    lpadmin -x "$PRINTER_NAME" 2>/dev/null || true
    rm -f /usr/lib/cups/filter/$FILTER_NAME
    rm -f /usr/lib/cups/backend/sharpipp
    echo "アンインストール完了"
    exit 0
fi

echo "  プリンター IP: $PRINTER_IP"
echo ""

# 依存パッケージのインストール
echo "[1/4] 必要なパッケージをインストール中..."
apt-get update -qq
apt-get install -y cups cups-filters ghostscript cups-ipp-utils avahi-daemon

# サービスを起動
echo "[2/4] サービスを起動中..."
systemctl enable --now cups avahi-daemon
sleep 2

# フィルター・バックエンドをインストール
echo "[3/4] ドライバーファイルをインストール中..."
install -m 755 "$SCRIPT_DIR/core/filter/$FILTER_NAME"   /usr/lib/cups/filter/$FILTER_NAME
install -m 700 "$SCRIPT_DIR/core/backend/sharpipp"      /usr/lib/cups/backend/sharpipp

# 既存キューを削除して再作成
lpadmin -x "$PRINTER_NAME" 2>/dev/null || true

echo "[4/4] プリンターキューを設定中..."
lpadmin -p "$PRINTER_NAME" \
    -v "sharpipp://${PRINTER_IP}:631/ipp/lp" \
    -P "$SCRIPT_DIR/drivers/sharp/BP-40C26/$PPD_FILE" \
    -D "SHARP BP-40C26" \
    -E

# デフォルトプリンターに設定
lpadmin -d "$PRINTER_NAME"

echo ""
echo "================================================"
echo "  Sharp BP Series CUPS Driver"
echo "  Version: $VERSION"
echo "================================================"
echo ""
echo "  インストール完了！"
echo ""
echo "  プリンター名:  $PRINTER_NAME"
echo "  PPDファイル:   /usr/share/cups/model/$PPD_FILE"
echo "  フィルター:    /usr/lib/cups/filter/$FILTER_NAME"
echo ""
echo "  テスト印刷:"
echo "    lp -d $PRINTER_NAME /usr/share/cups/data/default-testpage.pdf"
echo ""
echo "  ステータス確認:"
echo "    lpstat -p $PRINTER_NAME"
echo ""
echo "  アンインストール:"
echo "    sudo bash $0 --uninstall"
echo ""
echo "------------------------------------------------"
echo "  Developed by MetaDataLab Inc."
echo "  https://github.com/matsuokan/sharp-bp-cups-driver"
echo "  License: MIT"
echo "================================================"
