set -e

aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_1
aws ssm get-parameter --with-decryption --name $SSM_KMS_TEST_2
aws ssm get-parameter --with-decryption --name $SSM_SSM_TEST_1

curl https://$DNS_NAME/ | grep Hello world

