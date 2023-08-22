#

target="root@asv.ink:/var/www/asv.ink/ca"

# update certificate authority
mkdir ./ca_out
for d in $(ls "./ca/"); do 
    cp "./ca/$d/certs/ca-chain.crt" "./ca_out/$d-chain.crt"
    cp "./ca/$d/crl/ca.crl" "./ca_out/$d.crl"
done
rsync --stats -h --delete -z -ur ./ca_out/ $target
rm -rf ./ca_out
