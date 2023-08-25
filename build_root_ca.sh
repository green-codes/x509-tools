read -p "Name for new root CA database: " NAME
if ! [[ -d ca ]]; then mkdir ca; fi
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
openssl ca -config $DIR/openssl.cnf \
    -extensions v3_ca \
    -notext -md sha256 \
    -rand_serial -selfsign \
    $START $END $DAYS \
    -key $DIR/private/ca.key \
    -in $DIR/csr/ca.csr \
    -out $DIR/certs/ca.crt
cp $DIR/certs/ca.crt $DIR/certs/ca-chain.crt  # for daisy-chaining

echo -e "\n===== Creating CA CRL ====="
echo $(cat /dev/random | head -c20 | hexdump -vn20 -e'4/4 "%08X" 1 "\n"') > $DIR/crlnumber
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
