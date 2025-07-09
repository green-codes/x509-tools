read -p "Using CA (name): " CA_NAME
read -p "Certificate name: " CERT_NAME
CA_DIR="ca/$CA_NAME"
OUT_DIR="$HOME/Downloads"

if ! [[ -f $CA_DIR/certs/$CERT_NAME.crt ]]; then echo "Certificate does not exist!"; exit -1; fi
echo "Will output to $OUT_DIR/"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

openssl pkcs12 -export -out $OUT_DIR/$CERT_NAME.pfx -inkey $CA_DIR/private/$CERT_NAME.key -in $CA_DIR/certs/$CERT_NAME-chain.crt
