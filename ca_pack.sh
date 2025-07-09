# packs designated CA dir in working area to repo
SIGNER=1F517725
RECIPIENT=171DCA62
OUT_DIR="./repo"

if ! [[ $# == 1 ]]; then echo "Usage: $0 path/to/cert/dir"; exit; fi
OUT_FILE="$OUT_DIR/$(basename $1).tar.bz2.gpg"

echo "Signing with $SIGNER, encrypting to $RECIPIENT."
echo "Will package $1 to:\n > $OUT_FILE"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

if ! [[ -d $OUT_DIR ]]; then mkdir -p OUT_DIR; fi
tar -C $(dirname $1) -c $(basename $1) | pbzip2 | gpg -s -u $SIGNER -e -r $RECIPIENT > $OUT_FILE

read -p "Delete original? [y/N]: " VAR
if [[ $VAR =~ [Yy] ]]; then rm -rf $1; fi
