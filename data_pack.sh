# tar ball, bzip2 compress, sign and encrypt a directory

SIGNER=1F517725
RECIPIENT=171DCA62

if ! [[ $# == 1 ]]; then echo "Usage: $0 data_dir_to_pack"; exit -1; fi
DEST_FILE="../packages/x509_$1.tar.bz2.gpg"

echo "Directory to pack: $1/"
echo "Saving package to: $DEST_FILE"
echo "Signing with $SIGNER, encrypting to $RECIPIENT."
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi
read -p "Delete originals? [y/N]: " VAR

tar -c --use-compress-prog bzip2 $1 | \
    gpg -s -u $SIGNER -e -r $RECIPIENT -o $DEST_FILE
if [[ $VAR =~ [Yy] ]]; then rm -rf $1; fi
