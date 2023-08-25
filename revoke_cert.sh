read -p "Using CA (dir): " DIR
read -p "File prefix of certificate to revoke: " CN
DIR="ca/$DIR"

echo -e "\n===== Revoking Certificate Key ====="
openssl ca -config $DIR/openssl.cnf \
    -revoke $DIR/certs/$CN.crt

echo -e "\n===== Updating CA CRL ====="
echo $(cat /dev/random | head -c20 | hexdump -vn20 -e'4/4 "%08X" 1 "\n"') > $DIR/crlnumber
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl
