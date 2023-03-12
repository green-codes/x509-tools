#

SIGNER=581D7CF8
RECIPIENT=581D7CF8

CA_ROOT="./ca"
OUT_DIR="/Users/gcodes/Downloads"

echo "Will output to $OUT_DIR/"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

for d in $(ls $CA_ROOT); do
	tar -c $CA_ROOT/$d | pbzip2 | gpg -s -u $SIGNER -e -r $RECIPIENT > $OUT_DIR/$d.tar.bz2.gpg
done
