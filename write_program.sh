#!/bin/sh
set -eu

# 注意
#   WSL2 CLIで実行してください。
#   DevContainer内で実行してもプログラム書き込みできません。

# 使い方:
#   sudo chmod +x write_program.sh
#   ./write_program.sh /dev/ttyACM0 ./src
#
# 第1引数: シリアルポート (例: /dev/ttyACM0)
# 第2引数: ソースディレクトリ (例: ./src)


if [ "$#" -ne 2 ]; then
  echo "Usage: $0 SERIAL_PORT SRC_DIR" >&2
  echo "Example: $0 /dev/ttyACM0 ./src" >&2
  exit 1
fi

PORT="$1"
SRC_DIR="$2"

echo "[INFO] Using port: ${PORT}"
echo "[INFO] Source dir: ${SRC_DIR}"
echo "[INFO] ttyACM Identification Number"
ls -l /dev/ttyACM*
echo ""
arduino-cli compile -b arduino:avr:micro "${SRC_DIR}"
echo ""
echo "[INFO] compile succeeded."
echo ""
arduino-cli upload  -b arduino:avr:micro -p "${PORT}" "${SRC_DIR}"
echo "[INFO] write program succeeded."
