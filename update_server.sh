#!/bin/bash

target="root@k7gcl.xyz:/root/ci/landing-sites/www/k7gcl.xyz/ca"

mkdir ./ca_out
for d in $(ls "./ca/"); do
    echo "> $d"
    cp "./ca/$d/certs/ca-chain.crt" "./ca_out/$d-chain.crt"
    cp "./ca/$d/crl/ca.crl" "./ca_out/$d.crl"
done

read -p "Continue? [y/N]: " VAR
if [[ $VAR =~ [Yy] ]]; then
    rsync --stats -h --delete -z -ur ./ca_out/ $target
fi

rm -rf ./ca_out
