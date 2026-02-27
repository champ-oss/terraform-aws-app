set -e
if [ "$ENABLED" = "true" ]; then
  # Validate the values of the KMS SSM parameters "KMSTEST1" and "KMSTEST2"
  aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_1 --query 'Parameter.Value' | grep "kms secret 1"
  aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_2 --query 'Parameter.Value' | grep "kms secret 2"

  # Validate the KMS SSM parameter "SSMTEST2" which overrides a secret of the same name
  aws ssm get-parameter --with-decryption --name $SSM_SSM_TEST_1 --query 'Parameter.Value' | grep "kms secret 2"

    # Simple retry for curl (5 attempts, 30 sec apart)
    for i in {1..5}; do
      curl -s https://"$DNS_NAME"/ | grep "Hello world" && break
      echo "Curl attempt $i failed, retrying..."
      sleep 30
    done
   
else
  echo "Module is disabled, no resources created for this test"
fi