export AWS_ACCOUNT_ID=539854542450
export AWS_PROFILE=pablo.personal
export AWS_ECR_ENDPOINT=$AWS_ACCOUNT_ID.dkr.ecr.us-west-1.amazonaws.com

##############
# DEV
##############

# Build images
docker build \
  -f services/users/Dockerfile \
  -t $AWS_ECR_ENDPOINT/test-driven-users:dev \
  ./services/users

docker build \
  -f services/client/Dockerfile \
  -t $AWS_ECR_ENDPOINT/test-driven-client:dev \
  ./services/client

# Create ECR repositories
aws ecr create-repository --repository-name test-driven-users --region us-west-1
aws ecr create-repository --repository-name test-driven-clients --region us-west-1

# Authenticate the Docker CLI to AWS ECR
aws ecr get-login-password --region us-west-1 \
  | docker login --username AWS --password-stdin $AWS_ECR_ENDPOINT

# Push the images
docker push $AWS_ECR_ENDPOINT/test-driven-users:dev
docker push $AWS_ECR_ENDPOINT/test-driven-client:dev

##############
# PROD
##############

docker-compose -f docker-compose.prod.yml up --build
docker-compose -f docker-compose.prod.yml exec api python manage.py recreate_db
docker-compose -f docker-compose.prod.yml exec api python manage.py seed_db

docker build \
  -f services/users/Dockerfile.prod \
  -t $AWS_ECR_ENDPOINT/test-driven-users:prod \
  ./services/users

docker build \
  -f services/client/Dockerfile.prod \
  -t $AWS_ECR_ENDPOINT/test-driven-client:prod \
  ./services/client

docker push $AWS_ECR_ENDPOINT/test-driven-users:prod
docker push $AWS_ECR_ENDPOINT/test-driven-client:prod


