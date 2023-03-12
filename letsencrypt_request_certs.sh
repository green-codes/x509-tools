# request letsencrypt certificates

if ! [[ $# == 1 ]]; then echo "Usage: $0 your_domain.tld"; exit -1; fi
if ! [[ -d letsencrypt ]]; then echo "./letsencrypt not found!"; exit -1; fi

echo -e "Will request LetsEncrypt certificate for the following SANs:\n > $1\n > *.$1"
read -p "Continue? [y/N]: " VAR
if ! [[ $VAR =~ [Yy] ]]; then exit; fi

certbot certonly --manual --preferred-challenges dns \
    --work-dir letsencrypt --logs-dir letsencrypt/logs --config-dir letsencrypt \
    -d $1 -d *.$1
