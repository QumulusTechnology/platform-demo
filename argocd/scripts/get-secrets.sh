#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function is_bin_in_path {
  builtin type -P "$1" &> /dev/null
}

function get_secret_value {
    # Check if secret already exists and it is newer than the password
    if test -f ${SCRIPT_DIR}/.${1}-secret.txt; then
        if [ "${SCRIPT_DIR}/../../passwords/$1-password.txt" -ot "${SCRIPT_DIR}/.${1}-secret.txt" ]; then
            secret_value=$(cat ${SCRIPT_DIR}/.${1}-secret.txt)
        fi
    fi

    if [ "${secret_value}" == "" ]; then
        password=$(cat ${SCRIPT_DIR}/../../passwords/${1}-password.txt)

        if [ "${1}" == "argocd" ]; then
            secret_value=$(htpasswd -nbBC 10 "" "$password" | tr -d ':\n' | sed 's/$2y/$2a/')
        elif [ "${1}" == "loki" ] || [ "${1}" == "mimir" ]; then
            $(htpasswd -nbBC 10 admin "$password")
        fi

        echo "${secret_value}" > ${SCRIPT_DIR}/.${1}-secret.txt
    fi
    echo ${secret_value}
}

if ! is_bin_in_path htpasswd; then
    >&2 echo "htpasswd is not installed. cannot generate argocd secret"
    exit 1
fi

argocd_secret=$(get_secret_value argocd)
loki_secret=$(get_secret_value loki)
mimir_secret=$(get_secret_value mimir)

echo "{ \"argocd_secret\": \"${argocd_secret}\", \"loki_secret\": \"${loki_secret}\", \"mimir_secret\": \"${mimir_secret}\" }"
