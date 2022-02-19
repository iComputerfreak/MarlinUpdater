#!/bin/zsh
cd "$(dirname "$0")"

cd Marlin
platformio run -e STM32F103RC_btt

cp .pio/build/STM32F103RC_btt/firmware.bin ..
