#!/usr/bin/env bash
# installs the files to the required folder
CONFIG_FOLDER="$HOME/.conf/submodule_deepcopy"
[[ -f "config.conf" && -f "marker.mark" ]] || { echo "please use 'cd <deep_copy_submodules folder>' before running this script. abort."; exit 1;}
echo "inserting script path into config"
base=$(realpath ".")
sed  "s|\%PATH\%|$base|" config.conf > tmp.conf
mkdir -p "$CONFIG_FOLDER" && cp  tmp.conf "$CONFIG_FOLDER/config.conf" && rm tmp.conf && echo "installed deep_copy config into $CONFIG_FOLDER" && exit 0
echo "error while copying config $CONFIG_FOLDER"