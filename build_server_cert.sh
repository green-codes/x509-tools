read -p "Using CA (dir): " DIR
read -p "New file prefix: " CN

if [[ -e $DIR/private/$CN.key.pem ]]; then rm -f $DIR/private/$CN.key.pem; fi
if [[ -e $DIR/csr/$CN.csr.pem ]]; then rm -f $DIR/csr/$CN.csr.pem; fi
if [[ -e $DIR/certs/$CN.cert.pem ]]; then rm -f $DIR/certs/$CN.cert.pem; fi

echo -e "\n===== Creating Certificate Key ====="
openssl genrsa \
    -out $DIR/private/$CN.key.pem 2048
chmod 400 $DIR/private/$CN.key.pem

echo -e "\n===== Creating Certificate CSR ====="
openssl req -config $DIR/openssl.cnf \
    -key $DIR/private/$CN.key.pem \
    -new -sha256 -out $DIR/csr/$CN.csr.pem

echo -e "\n===== Signing Certificate ====="
read -p "Days valid [375]: " VAR
if [[ -z $VAR ]]; then DAYS=375; else DAYS=$VAR; fi
openssl ca -config $DIR/openssl.cnf \
    -extensions server_cert -days $DAYS -notext -md sha256 \
    -in $DIR/csr/$CN.csr.pem \
    -out $DIR/certs/$CN.cert.pem
chmod 444 $DIR/certs/$CN.cert.pem
