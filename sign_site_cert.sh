read -p "Using CA (dir): " DIR
read -p "Certificate file prefix: " CN
read -p "Use certificate extension: " EXT
DIR="ca/$DIR"

if [[ -e $DIR/certs/$CN.crt ]]; then rm -f $DIR/certs/$CN.crt; fi

echo -e "\n===== Signing Certificate ====="
read -p "Days valid [375]: " VAR
if [[ -z $VAR ]]; then DAYS=375; else DAYS=$VAR; fi
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
chmod 444 $DIR/certs/$CN.crt
