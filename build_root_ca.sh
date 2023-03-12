read -p "Name for new root CA database: " NAME
if ! [[ -d ca ]]; then mkdir ca; fi
DIR="ca/$NAME"

echo -e "\n===== Creating CA Database ====="
mkdir $DIR && cd $DIR
mkdir certs crl newcerts private
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
openssl genrsa -aes256 \
    -out $DIR/private/ca.key 4096
chmod 400 $DIR/private/ca.key

echo -e "\n===== Creating CA Certificate ====="
read -p "Days valid [7300]: " VAR
if [[ -z $VAR ]]; then DAYS=7300; else DAYS=$VAR; fi
openssl req -config $DIR/openssl.cnf \
    -key $DIR/private/ca.key \
    -new -x509 -days $DAYS -sha256 -extensions v3_ca \
    -out $DIR/certs/ca.crt
cp $DIR/certs/ca.crt $DIR/certs/ca-chain.crt  # for daisy-chaining

echo -e "\n===== Creating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
