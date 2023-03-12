# request letsencrypt certificates
SIGNER=1F517725
RECIPIENT=95377775  # ASTER Cert Deploy
OUT_DIR="/Users/gcodes/Credentials/public/encrypted"

if ! [[ $# == 1 ]]; then echo "Usage: $0 path/to/cert/dir"; exit; fi
OUT_FILE="$OUT_DIR/$(basename $1).tar.gpg"

echo "Signing with $SIGNER, encrypting to $RECIPIENT."
echo -e "Will package $1 to:\n > $OUT_FILE"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

cd $(dirname $1)
tar -cL $(basename $1) | gpg -s -u $SIGNER -e -r $RECIPIENT -o $OUT_FILE
