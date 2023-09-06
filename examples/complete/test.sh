set -e

aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_1 --query 'Parameter.Value'
aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_2 --query 'Parameter.Value'
aws ssm get-parameter --with-decryption --name $SSM_SSM_TEST_1 --query 'Parameter.Value'

curl https://$DNS_NAME/ | grep "Hello world"

