set -e
if [ "$ENABLED" = "true" ]; then
  curl -s "https://$DNS_NAME/" | grep "No valid routing rule"

  curl -s "https://${DNS_NAME}${ROUTE53_HEALTH_CHECK_RESOURCE_PATH}" | grep "PONG"
else
  echo "Module is disabled, no resources created"
fi