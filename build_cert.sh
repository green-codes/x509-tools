read -p "Using CA (dir): " DIR
read -p "New file prefix: " CN

if [[ -e $DIR/private/$CN.key ]]; then rm -f $DIR/private/$CN.key; fi
if [[ -e $DIR/csr/$CN.csr ]]; then rm -f $DIR/csr/$CN.csr; fi
if [[ -e $DIR/certs/$CN.crt ]]; then rm -f $DIR/certs/$CN.crt; fi
if [[ -e $DIR/certs/$CN-chain.crt ]]; then rm -f $DIR/certs/$CN-chain.crt; fi

echo -e "\n===== Creating Certificate Key ====="
openssl genrsa \
    -out $DIR/private/$CN.key 2048
chmod 400 $DIR/private/$CN.key

echo -e "\n===== Creating Certificate CSR ====="
openssl req -config $DIR/openssl.cnf \
    -key $DIR/private/$CN.key \
    -new -sha256 -out $DIR/csr/$CN.csr

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
        -in $DIR/csr/$CN.csr \
        -out $DIR/certs/$CN.crt
    rm $DIR/san.temp.cnf
else  # use vanilla configs
    openssl ca -config $DIR/openssl.cnf \
        -extensions $EXT \
        -days $DAYS -notext -md sha256 \
        -in $DIR/csr/$CN.csr \
        -out $DIR/certs/$CN.crt
fi
# make certificate chain by default
cat $DIR/certs/$CN.crt $DIR/certs/ca-chain.crt > $DIR/certs/$CN-chain.crt
chmod 444 $DIR/certs/$CN.crt $DIR/certs/$CN-chain.crt
