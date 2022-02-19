#!/bin/zsh

set -e

cd "$(dirname "$0")"

# Create version file
echo "0.0.0" > .current_version

# Create empty overrides
mkdir Overrides
touch Overrides/Configuration.h
touch Overrides/Configuration_adv.h

# Clone Marlin
git clone https://github.com/MarlinFirmware/Marlin

# Clone Marlin Configurations
git clone https://github.com/MarlinFirmware/Configurations
