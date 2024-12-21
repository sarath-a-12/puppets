#!/bin/bash
# Restrict access to files listed in restricted_directories.txt
while read -r file; do
    sudo setfacl -m o::0 "$file"
done < restricted_directories.txt
