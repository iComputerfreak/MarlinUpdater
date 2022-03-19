#!/bin/zsh

set -e

config_path="config/examples/AnyCubic/Mega Zero 2.0/Anycubic V1/"

cd "$(dirname "$0")"

echo "Checking for updates..."
current_version=$(head .current_version)
echo "Current version: $current_version"
cd Marlin
git fetch --tags
latest_version=$(git tag | tail -1)
echo "Latest version:  $latest_version"
cd ..

function update_marlin() {
    cd Marlin
    echo
    echo "Updating Marlin"
    git reset --hard
    git clean -fd
    git checkout -
    git pull
    git checkout tags/"$latest_version"
    cd ..

    echo
    echo "Updating Configurations"
    cd Configurations
    git reset --hard
    git clean -fd
    git checkout -
    git pull
    git checkout tags/"$latest_version"
    cd ..
}

if [[ "$1" != "-f" ]]; then
    # If there are no updates, exit
    autoload is-at-least
    # If the installed version is at least the latest version (cannot be newer so this is an equal check), exit
    is-at-least "$current_version" "$latest_version" && echo "No updates available." || echo "New version available!" || update_marlin
fi

cp "Configurations/$config_path/Configuration.h" "Marlin/Marlin/"
cp "Configurations/$config_path/Configuration_adv.h" "Marlin/Marlin/"
# Copy the Bootscreen, if it exists in the Overrides
if [[ -f "Overrides/_Bootscreen.h" ]]; then
    cp "Overrides/_Bootscreen.h" "Marlin/Marlin/"
fi
# Copy the Statusscreen, if it exists in the Overrides
if [[ -f "Overrides/_Statusscreen.h" ]]; then
    cp "Overrides/_Statusscreen.h" "Marlin/Marlin/"
fi

# For each line in the override files, replace the line in the real configuration, keeping the identation
cd Overrides

echo
echo "Writing overrides..."
for filename in Configuration.h Configuration_adv.h
do
    echo "  Configuring ${filename}..."
    while IFS='' read -r line || [ -n "${line}" ]
    do
        if [[ -n "$line" ]]; then
            # "#define PARAMETER"
            echo "    $line"

            # Escape the line's contents to prevent regex conflicts
            line_clean=$(echo "$line" | sed 's/\//\\\//g')
            query=$(echo "$line_clean" | cut -d ' ' -f1-2)
            # Remove leading // if present (query should not be commented out; leading // are already escaped)
            query="${query##\\/\\/}"

            # For all lines that match the regex "^( *)(\/\/)?($query) .*" (indentation, comment?, query, value)
            # Replace the match                       "(\/\/)?($query) .*" (comment?, query, value)
            # With $line_clean (whatever is in the overrides file)
            #echo "    Query: $query"
            #echo "    Replc: $line_clean"
            sed -i "" -E "/^( *)(\/\/)?($query)( |$).*/s/(\/\/)?($query)( |$).*/$line_clean/g" "../Marlin/Marlin/${filename}"
        fi
    done < "$filename"
done

if [[ -x "additional.sh" ]]; then
    ./additional.sh
fi

cd ..
echo "$latest_version" > .current_version
