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
cp openssl.cnf san_ext.cnf san_template.cnf $DIR/
sed -i "s/\[CA_DIR\]/$DIR/g" $DIR/openssl.cnf;
sed -i "s/\[CA_DIR\]/$DIR/g" $DIR/san_ext.cnf;
sed -i "s/\[CA_DIR\]/$DIR/g" $DIR/san_template.cnf;
read -p "Edit OpenSSL config? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then $EDITOR $DIR/openssl.cnf; fi

echo -e "\n===== Creating CA Key ====="
openssl genrsa -aes256 \
    -out $DIR/private/ca.key 4096
chmod 400 $DIR/private/ca.key

echo -e "\n===== Creating CA CSR ====="
openssl req -config $DIR/openssl.cnf -new -sha256 \
    -key $DIR/private/ca.key \
    -out $DIR/csr/ca.csr

echo -e "\n===== Signing CA Certificate ====="
read -p "Days valid [3650]: " VAR
if [[ -z $VAR ]]; then DAYS=3650; else DAYS=$VAR; fi
openssl ca -config $DIR_ROOT/openssl.cnf \
    -extensions v3_intermediate_ca \
    -days $DAYS -notext -md sha256 \
    -in $DIR/csr/ca.csr \
    -out $DIR/certs/ca.crt
chmod 444 $DIR/certs/ca.crt
# create certificate chain with root
cat $DIR/certs/ca.crt $DIR_ROOT/certs/ca-chain.crt \
    > $DIR/certs/ca-chain.crt
chmod 444 $DIR/certs/ca-chain.crt

echo -e "\n===== Verifying certificate against root CA ====="
openssl verify -CAfile $DIR_ROOT/certs/ca.crt \
    $DIR/certs/ca.crt

echo -e "\n===== Creating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl

echo -e "\n===== Synchronize Data to Server ====="
read -p "Sync to $SERVER_HOST? Y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then
    scp $DIR/certs/ca.crt $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crt
    scp $DIR/certs/ca-chain.crt $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR-chain.crt
    scp $DIR/crl/ca.crl $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crl
fi