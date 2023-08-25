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
read -p "Start Date (YYYYmmDDHHMMSSZ) [NOW]: " VAR
if ! [[ -z $VAR ]]; then 
    START="-startdate $VAR";
    read -p "End Date (YYYYmmDDHHMMSSZ): " VAR
    if ! [[ -z $VAR ]]; then END="-enddate $VAR"; fi
fi
if [[ -z $END ]]; then
    read -p "Days valid from now [7300]: " VAR
    if [[ -z $VAR ]]; then DAYS="-days 7300"; else DAYS="-days $VAR"; fi
fi
openssl ca -config $DIR_ROOT/openssl.cnf \
    -extensions v3_intermediate_ca \
    -notext -md sha256 \
    -rand_serial \
    $START $END $DAYS \
    -in $DIR/csr/ca.csr \
    -out $DIR/certs/ca.crt
chmod 444 $DIR/certs/ca.crt
cp $DIR/certs/ca.crt $DIR_ROOT/certs/$NAME.crt
# create certificate chain with root
cat $DIR/certs/ca.crt $DIR_ROOT/certs/ca-chain.crt \
    > $DIR/certs/ca-chain.crt
cp $DIR/certs/ca-chain.crt $DIR_ROOT/certs/$NAME-chain.crt
chmod 444 $DIR/certs/ca-chain.crt $DIR_ROOT/certs/$NAME-chain.crt

echo -e "\n===== Verifying certificate against root CA ====="
openssl verify -CAfile $DIR_ROOT/certs/ca-chain.crt \
    $DIR/certs/ca.crt

echo -e "\n===== Creating CA CRL ====="
echo $(cat /dev/random | head -c20 | hexdump -vn20 -e'4/4 "%08X" 1 "\n"') > $DIR/crlnumber
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
