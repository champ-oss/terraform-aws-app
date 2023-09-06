set -e

# Validate the values of the KMS SSM parameters "KMSTEST1" and "KMSTEST2"
aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_1 --query 'Parameter.Value' | grep "kms secret 1"
aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_2 --query 'Parameter.Value' | grep "kms secret 2"

# Validate the KMS SSM parameter "SSMTEST2" which overrides a secret of the same name
aws ssm get-parameter --with-decryption --name $SSM_SSM_TEST_1 --query 'Parameter.Value' | grep "kms secret 2

curl -s https://$DNS_NAME/ | grep "Hello world"

