read -p "Using CA (name): " CA_NAME
read -p "Certificate name: " CERT_NAME
CA_DIR="ca/$CA_NAME"
OUT_DIR="$HOME/Downloads"

if ! [[ -f $CA_DIR/certs/$CERT_NAME.crt ]]; then echo "Certificate does not exist!"; exit -1; fi
echo "Will output to $OUT_DIR/$CERT_NAME/"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

mkdir $OUT_DIR/$CERT_NAME
cp $CA_DIR/certs/$CERT_NAME.crt $OUT_DIR/$CERT_NAME/cert.pem
cp $CA_DIR/certs/$CERT_NAME-chain.crt $OUT_DIR/$CERT_NAME/fullchain.pem
cp $CA_DIR/certs/ca-chain.crt $OUT_DIR/$CERT_NAME/chain.pem
cp $CA_DIR/private/$CERT_NAME.key $OUT_DIR/$CERT_NAME/privkey.pem
