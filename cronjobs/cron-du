#!/bin/bash
#
# Check the size of a directory and write the output to a file for bloonix-agent


target_dir="$1"
target_dir_filenamed="$(echo $target_dir | sed -e 's@^/@@g' -e 's@/@_@g' )"
result_file="/var/lib/bloonix/agent/du_result/${target_dir_filenamed}.json"
mkdir -p /var/lib/bloonix/agent/du_result


if [[ -z $target_dir ]]; then
    echo "Please specify the full path to the directory to check, aborting!"
    exit 1
fi


dir_size_bytes="$(du -sx $target_dir 2>/dev/null | awk '{print $1}')"
dir_inodes="$(find $target_dir | wc -l 2>/dev/null)"


echo "{
  size: $dir_size_bytes,
  inodes: $dir_inodes
}" > "$result_file"
