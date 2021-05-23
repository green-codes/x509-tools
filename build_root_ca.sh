SERVER_HOST=ministry-mas.com
SERVER_USER=root

read -p "Dir for new root CA database: " DIR

echo -e "\n===== Creating CA Database ====="
mkdir $DIR && cd $DIR
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo -e 1000 > serial
echo -e 1000 > crlnumber
cd ..
# copy openssl config
cp openssl.cnf san_ext.cnf san_template.cnf $DIR/
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

echo -e "\n===== Creating CA Certificate ====="
read -p "Days valid [7300]: " VAR
if [[ -z $VAR ]]; then DAYS=7300; else DAYS=$VAR; fi
openssl req -config $DIR/openssl.cnf \
    -key $DIR/private/ca.key.pem \
    -new -x509 -days $DAYS -sha256 -extensions v3_ca \
    -out $DIR/certs/ca.cert.pem
cp $DIR/certs/ca.cert.pem $DIR/certs/ca-chain.cert.pem  # for daisy-chaining

echo -e "\n===== Creating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl.pem

echo -e "\n===== Synchronize Data to Server ====="
read -p "Sync to $SERVER_HOST? Y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then
    scp $DIR/certs/ca.cert.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.cert.pem
    scp $DIR/crl/ca.crl.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crl.pem
fi