read -p "Name for root CA database: " NAME_ROOT
read -p "Name for new intermediate CA database: " NAME
DIR_ROOT="ca/$NAME_ROOT"
DIR="ca/$NAME"

echo -e "\n===== Creating CA Database ====="
mkdir $DIR && cd $DIR
mkdir certs crl csr newcerts private
chmod 700 private
mkdir private/newkeys
chmod 700 private/newkeys
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
cd -
# copy openssl config
cp openssl.cnf san_ext.cnf san_template.cnf $DIR/
sed -i "s/\[CA_NAME\]/$NAME/g" $DIR/openssl.cnf;
sed -i "s/\[CA_NAME\]/$NAME/g" $DIR/san_ext.cnf;
sed -i "s/\[CA_NAME\]/$NAME/g" $DIR/san_template.cnf;
read -p "Edit OpenSSL config? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then $EDITOR $DIR/openssl.cnf; fi

echo -e "\n===== Creating CA Key ====="
read -p "Password-protect private key? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then ENC="-aes256"; else ENC=""; fi
openssl genpkey $ENC \
    -algorithm RSA -pkeyopt rsa_keygen_bits:4096 \
    -out $DIR/private/ca.key
chmod 400 $DIR/private/ca.key

echo -e "\n===== Creating CA CSR ====="
openssl req -utf8 -config $DIR/openssl.cnf -new -sha256 \
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
cp $DIR/certs/ca.crt $DIR_ROOT/certs/$NAME.crt
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
