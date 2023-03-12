#

CA_ROOT="./ca"
DEST="/Users/gcodes/Downloads"

echo "Will output to $DEST/"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

for f in $(ls $CA_ROOT); do
	cp $CA_ROOT/$f/certs/ca.crt $DEST/$f.crt
	cp $CA_ROOT/$f/certs/ca-chain.crt $DEST/$f-chain.crt
	cp $CA_ROOT/$f/crl/ca.crl $DEST/$f.crl
done
