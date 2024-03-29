# request letsencrypt certificates
SIGNER=581D7CF8  #1F517725
RECIPIENT=581D7CF8  #171DCA62
OUT_DIR="/Users/gcodes/Confidential/vault/ca"

if ! [[ $# == 1 ]]; then echo "Usage: $0 path/to/cert/dir"; exit; fi
OUT_FILE="$OUT_DIR/$(basename $1).tar.bz2.gpg"

echo "Signing with $SIGNER, encrypting to $RECIPIENT."
echo "Will package $1 to:\n > $OUT_FILE"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

tar -C $(dirname $1) -c $(basename $1) | pbzip2 | gpg -s -u $SIGNER -e -r $RECIPIENT > $OUT_FILE

read -p "Delete original? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi
rm -rf $1
