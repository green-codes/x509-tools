SERVER_HOST=ministry-mas.com
SERVER_USER=root

read -p "Dir for root CA database: " DIR_ROOT
read -p "Dir for new intermediate CA database: " DIR

echo -e "\n===== Creating CA Database ====="
mkdir $DIR && cd $DIR
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo -e 1000 > serial
echo -e 1000 > crlnumber
cd ..
# copy openssl config
cp openssl_intermediate.cnf $DIR/openssl.cnf
if [[ `uname` == "Darwin" ]]; then
    sed -i '' "s/\[CA_DIR\]/$DIR/g" $DIR/openssl.cnf;
else
    sed -i "s/\[CA_DIR\]/$DIR/g" $DIR/openssl.cnf;
fi
read -p "Edit OpenSSL config? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then $EDITOR $DIR/openssl.cnf; fi

echo -e "\n===== Creating CA Key ====="
openssl genrsa -aes256 \
    -out $DIR/private/ca.key.pem 4096
chmod 400 $DIR/private/ca.key.pem

echo -e "\n===== Creating CA CSR ====="
openssl req -config $DIR/openssl.cnf -new -sha256 \
    -key $DIR/private/ca.key.pem \
    -out $DIR/csr/ca.csr.pem

echo -e "\n===== Signing CA Certificate ====="
read -p "Days valid [3650]: " VAR
if [[ -z $VAR ]]; then DAYS=3650; else DAYS=$VAR; fi
openssl ca -config $DIR_ROOT/openssl.cnf \
    -extensions v3_intermediate_ca \
    -days $DAYS -notext -md sha256 \
    -in $DIR/csr/ca.csr.pem \
    -out $DIR/certs/ca.cert.pem
chmod 444 $DIR/certs/ca.cert.pem
# create certificate chain with root
cat $DIR/certs/ca.cert.pem $DIR_ROOT/certs/ca.cert.pem \
    > $DIR/certs/ca-chain.cert.pem
chmod 444 $DIR/certs/ca-chain.cert.pem

echo -e "\n===== Verifying certificate against root CA ====="
openssl verify -CAfile $DIR_ROOT/certs/ca.cert.pem \
    $DIR/certs/ca.cert.pem

echo -e "\n===== Creating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl.pem

echo -e "\n===== Synchronize Data to Server ====="
read -p "Sync to $SERVER_HOST? Y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then
    scp $DIR/certs/ca.cert.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.cert.pem
    scp $DIR/certs/ca-chain.cert.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR-chain.cert.pem
    scp $DIR/crl/ca.crl.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crl.pem
fi