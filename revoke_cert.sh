read -p "Using CA (dir): " DIR
read -p "File prefix of certificate to revoke: " CN
DIR="ca/$DIR"

echo -e "\n===== Revoking Certificate Key ====="
openssl ca -config $DIR/openssl.cnf \
    -revoke $DIR/certs/$CN.crt

echo -e "\n===== Updating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
