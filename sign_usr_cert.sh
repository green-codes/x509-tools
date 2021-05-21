read -p "Using CA (dir): " DIR
read -p "Certificate file prefix: " CN

if [[ -e $DIR/certs/$CN.cert.pem ]]; then rm -f $DIR/certs/$CN.cert.pem; fi

echo -e "\n===== Signing Certificate ====="
read -p "Days valid [375]: " VAR
if [[ -z $VAR ]]; then DAYS=375; else DAYS=$VAR; fi
openssl ca -config $DIR/openssl.cnf \
    -extensions server_cert -days $DAYS -notext -md sha256 \
    -in $DIR/csr/$CN.csr.pem \
    -out $DIR/certs/$CN.cert.pem
chmod 444 $DIR/certs/$CN.cert.pem
