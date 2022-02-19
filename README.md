# Marlin Updater

I wrote this script to keep track of all the modifications I made to my Marlin build and to easily update Marlin without needing to make all the modifications again.
The scripts use some zsh-only features, which is why they specify the `#/bin/zsh` shebang at the start.

## Installation

The `install.sh` script creates the neccessary files and folders and clones the Marlin and Marlin Configurations repositories.

This script creates the following files and folders:

```
.
├── .current_version   <- the version that was last updated to, using the update.sh script
├── Configurations     <- clone of https://github.com/MarlinFirmware/Configurations
├── Marlin             <- clone of https://github.com/MarlinFirmware/Marlin
└── Overrides          <- Configuration.h and Configuration_adv.h with the overriding values (all lines without any indentation)
```

After installing everything, you may want to change the default configuration to use (the variable `config_path` in `update.sh`).

You also may need to change the environment PlatformIO uses to build in `build.sh`. The default is `STM32F103RC_btt`.


## Usage

The `update.sh` script checks if the latest Marlin version available is newer than the current version stored in the file `.current_version`.
If there is a newer Marlin version available, the script pulls both the Marlin updates and the Configuration updates.
It then copies the configuration files into the Marlin repository and applies any overrides specified.

Use `./update.sh -f` to skip the version check and pull from the Marlin and Configurations repository anyways.

### Overrides
The overrides are placed directly into the `Configuration.h` and `Configuration_adv.h` files in the `Overrides` folder. Just copy the line that you want to change over from the real Marlin configuration and change it as you wish.

Make sure to remove any indentation in your override file, otherwise the indentation in the overrides file will be added to the indentation that is already in the original file.

The update script will copy the base configuration into the Marlin directory and then go over the override files line-by-line and replace the whole line with the matching settings key in the Marlin configuration.

## Building

After executing the `update.sh` script, the `build.sh` script builds marlin using PlatformIO.
You need to replace the `STM32F103RC_btt` environment with the environment you want to build Marlin with in `build.sh`.
