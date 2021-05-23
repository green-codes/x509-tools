read -p "Using CA (dir): " DIR

SERVER_HOST=ministry-mas.com
SERVER_USER=root

echo -e "\n===== Updating CA CRL ====="
openssl ca -config $DIR/openssl.cnf \
    -gencrl -out $DIR/crl/ca.crl

echo -e "\n===== Synchronize Data to Server ====="
read -p "Sync to $SERVER_HOST? Y/[N]: " VAR
if [[ $VAR =~ ^[Yy]$ ]]; then
    scp $DIR/crl/ca.crl $SERVER_USER@$SERVER_HOST:/srv/ftp/$DIR.crl
fi
