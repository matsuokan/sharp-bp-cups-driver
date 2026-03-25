#!/bin/bash
# ============================================================
# SHARP BP シリーズ + 各社複合機 CUPS ドライバー インストーラー
# 対応: Debian 12+ / Ubuntu 22.04+
# 使い方: sudo bash install.sh [IPアドレス] [メーカー] [機種]
# 例:     sudo bash install.sh 192.168.1.100 sharp BP-40C26
# 自動:   sudo bash install.sh 192.168.1.100
# ============================================================

set -e
VERSION="1.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ===== アンインストール =====
if [ "$1" = "--uninstall" ]; then
    if [ "$(id -u)" -ne 0 ]; then echo "sudo で実行してください"; exit 1; fi
    PRINTER_NAME="${2:-SHARP-BP40C26}"
    echo "アンインストール中: $PRINTER_NAME"
    lpadmin -x "$PRINTER_NAME" 2>/dev/null || true
    rm -f /usr/lib/cups/filter/pdftourf /usr/lib/cups/backend/sharpipp
    echo "完了"
    exit 0
fi

# ===== 引数処理 =====
PRINTER_IP="${1:?使い方: sudo bash $0 [IPアドレス] [メーカー(任意)] [機種(任意)]}"
VENDOR_ARG="${2,,}"   # lowercase
MODEL_ARG="${3}"

echo "================================================"
echo "  Sharp BP Series CUPS Driver"
echo "  Version: $VERSION"
echo "================================================"

if [ "$(id -u)" -ne 0 ]; then
    echo "エラー: sudo で実行してください"
    exit 1
fi

# ===== 機種選択 =====
select_model() {
    echo ""
    echo "対応機種一覧:"
    echo ""
    echo "  [SHARP]"
    echo "    1) BP-40C26  (確認済み✅)"
    echo "    2) MX-3070"
    echo "    3) MX-4070"
    echo "  [RICOH]"
    echo "    4) IM-2702"
    echo "    5) MP-C3004"
    echo "  [Canon]"
    echo "    6) iRADV-C3826"
    echo "    7) imageRUNNER-2625"
    echo "  [Konica Minolta]"
    echo "    8) bizhub-C3320i"
    echo "    9) bizhub-C458"
    echo "  [Kyocera]"
    echo "   10) TASKalfa-2553ci"
    echo "   11) ECOSYS-M6635cidn"
    echo "  [Fujifilm]"
    echo "   12) Apeos-C3571"
    echo "   13) DocuCentre-VI-C2271"
    echo "  [Toshiba]"
    echo "   14) e-STUDIO-2518A"
    echo "   15) e-STUDIO-4518A"
    echo ""
    read -rp "番号を選択してください [1-15]: " SEL
    case "$SEL" in
        1) VENDOR="sharp"; MODEL="BP-40C26"; PRINTER_NAME="SHARP-BP40C26"; IPP_PATH="/ipp/lp" ;;
        2) VENDOR="sharp"; MODEL="MX-3070"; PRINTER_NAME="SHARP-MX-3070"; IPP_PATH="/ipp/lp" ;;
        3) VENDOR="sharp"; MODEL="MX-4070"; PRINTER_NAME="SHARP-MX-4070"; IPP_PATH="/ipp/lp" ;;
        4) VENDOR="ricoh"; MODEL="IM-2702"; PRINTER_NAME="RICOH-IM-2702"; IPP_PATH="/printer" ;;
        5) VENDOR="ricoh"; MODEL="MP-C3004"; PRINTER_NAME="RICOH-MP-C3004"; IPP_PATH="/printer" ;;
        6) VENDOR="canon"; MODEL="iRADV-C3826"; PRINTER_NAME="Canon-iRADV-C3826"; IPP_PATH="/ipp/print" ;;
        7) VENDOR="canon"; MODEL="imageRUNNER-2625"; PRINTER_NAME="Canon-imageRUNNER-2625"; IPP_PATH="/ipp/print" ;;
        8) VENDOR="konica"; MODEL="bizhub-C3320i"; PRINTER_NAME="Konica-bizhub-C3320i"; IPP_PATH="/ipp/print" ;;
        9) VENDOR="konica"; MODEL="bizhub-C458"; PRINTER_NAME="Konica-bizhub-C458"; IPP_PATH="/ipp/print" ;;
       10) VENDOR="kyocera"; MODEL="TASKalfa-2553ci"; PRINTER_NAME="Kyocera-TASKalfa-2553ci"; IPP_PATH="/ipp" ;;
       11) VENDOR="kyocera"; MODEL="ECOSYS-M6635cidn"; PRINTER_NAME="Kyocera-ECOSYS-M6635cidn"; IPP_PATH="/ipp" ;;
       12) VENDOR="fujifilm"; MODEL="Apeos-C3571"; PRINTER_NAME="Fujifilm-Apeos-C3571"; IPP_PATH="/ipp/print" ;;
       13) VENDOR="fujifilm"; MODEL="DocuCentre-VI-C2271"; PRINTER_NAME="Fujifilm-DocuCentre-VI-C2271"; IPP_PATH="/ipp/print" ;;
       14) VENDOR="toshiba"; MODEL="e-STUDIO-2518A"; PRINTER_NAME="Toshiba-e-STUDIO-2518A"; IPP_PATH="/ipp/print" ;;
       15) VENDOR="toshiba"; MODEL="e-STUDIO-4518A"; PRINTER_NAME="Toshiba-e-STUDIO-4518A"; IPP_PATH="/ipp/print" ;;
        *) echo "無効な選択です"; exit 1 ;;
    esac
}

# 引数指定 or 対話式
if [ -n "$VENDOR_ARG" ] && [ -n "$MODEL_ARG" ]; then
    VENDOR="$VENDOR_ARG"
    MODEL="$MODEL_ARG"
    # IPPパスをvendorで判定
    case "$VENDOR" in
        sharp)   IPP_PATH="/ipp/lp" ;;
        ricoh)   IPP_PATH="/printer" ;;
        kyocera) IPP_PATH="/ipp" ;;
        *)       IPP_PATH="/ipp/print" ;;
    esac
    PRINTER_NAME="${VENDOR^^}-${MODEL}"
else
    select_model
fi

PPD_FILE="$SCRIPT_DIR/drivers/$VENDOR/$MODEL/"*.ppd
PPD_FILE=$(ls $PPD_FILE 2>/dev/null | head -1)

if [ -z "$PPD_FILE" ]; then
    echo "エラー: PPDが見つかりません: drivers/$VENDOR/$MODEL/"
    exit 1
fi

echo ""
echo "  プリンター IP:  $PRINTER_IP"
echo "  メーカー/機種:  $VENDOR / $MODEL"
echo "  キュー名:       $PRINTER_NAME"
echo ""

# ===== インストール =====
echo "[1/4] 必要なパッケージをインストール中..."
apt-get update -qq
apt-get install -y cups cups-filters ghostscript cups-ipp-utils avahi-daemon

echo "[2/4] サービスを起動中..."
systemctl enable --now cups avahi-daemon
sleep 2

echo "[3/4] ドライバーファイルをインストール中..."
install -m 755 "$SCRIPT_DIR/core/filter/pdftourf"   /usr/lib/cups/filter/pdftourf
install -m 700 "$SCRIPT_DIR/core/backend/sharpipp"  /usr/lib/cups/backend/sharpipp

echo "[4/4] プリンターキューを設定中..."
lpadmin -x "$PRINTER_NAME" 2>/dev/null || true
lpadmin -p "$PRINTER_NAME" \
    -v "sharpipp://${PRINTER_IP}:631${IPP_PATH}" \
    -P "$PPD_FILE" \
    -D "$MODEL" \
    -E
lpadmin -d "$PRINTER_NAME"

# ===== 完了 =====
echo ""
echo "================================================"
echo "  Sharp BP Series CUPS Driver"
echo "  Version: $VERSION"
echo "================================================"
echo ""
echo "  インストール完了！"
echo ""
echo "  プリンター名:  $PRINTER_NAME"
echo "  PPDファイル:   $PPD_FILE"
echo "  フィルター:    /usr/lib/cups/filter/pdftourf"
echo ""
echo "  テスト印刷:"
echo "    lp -d $PRINTER_NAME /usr/share/cups/data/default-testpage.pdf"
echo ""
echo "  ステータス確認:"
echo "    lpstat -p $PRINTER_NAME"
echo ""
echo "  アンインストール:"
echo "    sudo bash $0 --uninstall $PRINTER_NAME"
echo ""
echo "------------------------------------------------"
echo "  Developed by MetaDataLab Inc."
echo "  https://github.com/matsuokan/jpn-mfp-cups-driver"
echo "  License: MIT"
echo "================================================"
