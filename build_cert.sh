read -p "Using CA (name): " NAME_CA
read -p "Name for new certificate: " NAME
DIR="ca/$NAME_CA"

if [[ -e $DIR/private/$NAME.key ]]; then rm -f $DIR/private/$NAME.key; fi
if [[ -e $DIR/csr/$NAME.csr ]]; then rm -f $DIR/csr/$NAME.csr; fi
if [[ -e $DIR/certs/$NAME.crt ]]; then rm -f $DIR/certs/$NAME.crt; fi
if [[ -e $DIR/certs/$NAME-chain.crt ]]; then rm -f $DIR/certs/$NAME-chain.crt; fi

echo -e "\n===== Creating Certificate Key ====="
read -p "Password-protect private key? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then ENC="-aes256"; else ENC=""; fi
openssl genpkey $ENC \
    -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -out $DIR/private/$NAME.key
chmod 400 $DIR/private/$NAME.key
cp $DIR/private/$NAME.key $DIR/private/newkeys/$(cat $DIR/serial).key

echo -e "\n===== Creating Certificate CSR ====="
openssl req -utf8 -config $DIR/openssl.cnf \
    -key $DIR/private/$NAME.key \
    -new -sha256 -out $DIR/csr/$NAME.csr

echo -e "\n===== Signing Certificate ====="
read -p "Days valid [375]: " VAR
if [[ -z $VAR ]]; then DAYS=375; else DAYS=$VAR; fi
read -p "Use certificate extension [site_cert]: " VAR
if [[ -z $VAR ]]; then EXT="site_cert"; else EXT=$VAR; fi
read -p "Use Subject Alternative Name (SAN)? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; 
then  # use the SAN extension
    cp $DIR/san_template.cnf $DIR/san.temp.cnf
    $EDITOR $DIR/san.temp.cnf
    openssl ca -config $DIR/openssl.cnf \
        -extensions $EXT \
        -extfile $DIR/san.temp.cnf \
        -days $DAYS -notext -md sha256 \
        -rand_serial \
        -in $DIR/csr/$NAME.csr \
        -out $DIR/certs/$NAME.crt
    rm $DIR/san.temp.cnf
else  # use vanilla configs
    openssl ca -config $DIR/openssl.cnf \
        -extensions $EXT \
        -days $DAYS -notext -md sha256 \
        -rand_serial \
        -in $DIR/csr/$NAME.csr \
        -out $DIR/certs/$NAME.crt
fi
# make certificate chain by default
cat $DIR/certs/$NAME.crt $DIR/certs/ca-chain.crt > $DIR/certs/$NAME-chain.crt
chmod 444 $DIR/certs/$NAME.crt $DIR/certs/$NAME-chain.crt

echo -e "\n===== Verifying certificate against root CA ====="
openssl verify -CAfile $DIR/certs/ca-chain.crt \
    $DIR/certs/$NAME.crt
