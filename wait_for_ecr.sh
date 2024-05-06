if [ ! -z $DISABLED ]; then exit 0; fi

REGISTRY_ID=$(echo $IMAGE | cut -d'.' -f1)
ECR_REPO=$(echo $IMAGE | cut -d'/' -f2 | cut -d':' -f1)
IMAGE_TAG=$(echo $IMAGE | cut -d':' -f2)

n=0
until [ "$n" -ge $RETRIES ]
do
  aws ecr batch-get-image \
    --region $AWS_REGION \
    --repository-name $ECR_REPO \
    --image-ids imageTag=$IMAGE_TAG \
    --registry-id $REGISTRY_ID | jq -e '.images[0]' && exit 0
  echo "ECR image tag not found: $IMAGE_TAG"
  n=$((n+1))
  sleep $SLEEP
done

echo "Timed out"
exit 1