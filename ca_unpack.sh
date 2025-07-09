# unpacks designated CA archive to working dir
OUT_DIR="./ca"

if ! [[ $# == 1 ]]; then echo "Usage: $0 path/to/ca.tar.bz2.gpg"; exit; fi

echo -e "Will unpack $1 to:\n > $OUT_DIR"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

if ! [[ -e $OUT_DIR ]]; then mkdir -p $OUT_DIR; fi
cat $1 | gpg -d | pbzip2 -d | tar -C $OUT_DIR -x
