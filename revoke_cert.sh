SERVER_HOST=ministry-mas.com
SERVER_USER=root

read -p "Using CA (dir): " DIR
read -p "File prefix of certificate to revoke: " CN

echo -e "\n===== Revoking Certificate Key ====="
openssl ca -config $DIR/openssl.cnf \
    -revoke $DIR/certs/$CN.cert.pem

echo -e "\n===== Updating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl.pem

echo -e "\n===== Synchronize Data to Server ====="
read -p "Sync to $SERVER_HOST? Y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then
    scp $DIR/crl/ca.crl.pem $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crl.pem
fi