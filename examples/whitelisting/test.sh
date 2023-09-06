set -e

curl -s https://$DNS_NAME/ | grep "No valid routing rule"

curl -s https://$DNS_NAME/ping | grep "PONG"