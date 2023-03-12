read -p "Using CA (dir): " DIR
DIR="ca/$DIR"

echo -e "\n===== Updating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
