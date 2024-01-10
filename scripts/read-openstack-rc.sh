#!/usr/bin/env bash

FILEPATH=$1

source $FILEPATH

arr=(
    "OS_PROJECT_NAME"
    "OS_USERNAME"
    "OS_PASSWORD"
    "OS_AUTH_URL"
)

len=${#arr[@]}
counter=1
output="{"

for v in "${arr[@]}"; do
    output="${output}\"${v}\":\"${!v}\""
    if (( $counter < $len )); then
        output="${output},"
    fi
    counter=$((counter+1))
done

output+="}"

echo $output
