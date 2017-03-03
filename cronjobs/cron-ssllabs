#!/bin/bash
#
# Use and run https://github.com/ssllabs/ssllabs-scan and save the results to a file

ssllabs_executable="/usr/local/sbin/ssllabs-scan"

target_url="$1"
target_url_filenamed="$(echo $target_url | sed -e 's@^http://@@g' -e 's@https://@@g' -e 's@/$@@g' -e 's@/@_@g' )"
result_file="/var/lib/bloonix/agent/ssllabs_result/${target_url_filenamed}.txt"

mkdir -p /var/lib/bloonix/agent/ssllabs_result


if [[ -z $target_dir ]]; then
    echo "Please specify the full URL to check (https://www.example.com), aborting!"
    exit 1
fi

$ssllabs_executable "$target_url" > "$result_file"
