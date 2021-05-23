read -p "Using CA (dir): " DIR
read -p "Certificate file prefix: " CN

if [[ -e $DIR/certs/$CN.cert.pem ]]; then rm -f $DIR/certs/$CN.cert.pem; fi

echo -e "\n===== Signing Certificate ====="
read -p "Days valid [375]: " VAR
if [[ -z $VAR ]]; then DAYS=375; else DAYS=$VAR; fi
read -p "Use Subject Alternative Name (SAN)? y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; 
then  # use the SAN extension
    cp $DIR/san_template.cnf $DIR/san.temp.cnf
    $EDITOR $DIR/san.temp.cnf
    openssl ca -config $DIR/openssl.cnf \
        -extensions usr_cert \
        -extfile $DIR/san.temp.cnf \
        -days $DAYS -notext -md sha256 \
        -in $DIR/csr/$CN.csr.pem \
        -out $DIR/certs/$CN.cert.pem
    rm $DIR/san.temp.cnf
else  # use vanilla configs
    openssl ca -config $DIR/openssl.cnf \
        -extensions usr_cert \
        -days $DAYS -notext -md sha256 \
        -in $DIR/csr/$CN.csr.pem \
        -out $DIR/certs/$CN.cert.pem
fi
chmod 444 $DIR/certs/$CN.cert.pem
