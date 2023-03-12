# unpack to sandbox

if ! [[ $# == 1 ]]; then echo "Usage: $0 path/to/archive"; exit -1; fi
DEST_DIR="."

echo "Unpacking $1 to: $DEST_DIR/"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

gpg -d $1 | tar -x
