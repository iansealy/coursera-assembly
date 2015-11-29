#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 URL prefix"
    exit 1
fi

url="$1"
prefix="$2"

file=`echo "$url" | sed -e 's/.*\///'`
rm -f "$file"
wget -q "$url"
dos2unix -q "$file"

input="$prefix-extra-input.txt"
output="$prefix-extra-output.txt"
cat /dev/null > "$input"
cat /dev/null > "$output"

current="$input"
while IFS='' read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ ^Input ]]; then
        continue
    fi
    if [[ "$line" =~ ^Output ]]; then
        current="$output"
        continue
    fi
    echo "$line" >> $current
done < "$file"
