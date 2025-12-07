#!/bin/bash
set -xeuo pipefail

. ~/esp-idf/export.sh

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ ! -d "$DIR/build" ]; then
    idf.py set-target esp32s3
fi

idf.py build
sudo chmod a+rw /dev/ttyACM0
idf.py -p /dev/ttyACM0 flash
idf.py -p /dev/ttyACM0 monitor
