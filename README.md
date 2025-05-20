**Terraform**
terraform init
terraform plan
terraform apply

**Authenticate Docker with ECR**
aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com

**Build the Docker image**
# Patient Service
docker build -t patient-service .

# Appointment Service
docker build -t appointment-service .

**Tag the image for ECR**
docker tag patient-service:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/patient-service
docker tag appointment-service:latest <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/appointment-service

**Push the image to ECR**
docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/patient-service
docker push <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/appointment-service

**Verify**
aws ecr describe-images --repository-name patient-service
aws ecr describe-images --repository-name appointment-service

**Apply the Manifests**
kubectl apply -f k8s/patient-service/
kubectl apply -f k8s/appointment-service/
kubectl apply -f k8s/ingress.yaml

**Test Access**
After applying, test using the domain or load balancer DNS name:

http://<ALB-DNS>/patients

http://<ALB-DNS>/appointments


