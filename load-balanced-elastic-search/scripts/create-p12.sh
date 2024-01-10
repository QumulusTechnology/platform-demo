#!/usr/bin/env bash

cmd=openssl
[[ $(type -P "$cmd") ]] || { echo "$cmd is NOT in PATH" 1>&2; exit 1; }

openssl pkcs12 -export -password pass: -out load-balancer-cert.p12 -inkey load-balancer-key.pem -in load-balancer-cert.pem
