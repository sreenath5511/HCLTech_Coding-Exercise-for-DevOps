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

**Amazon CloudWatch (Logging & Metrics)**
Step 1: Enable CloudWatch Logging for EKS
resource "aws_eks_cluster" "hackathon" {
  name     = "hackathon-cluster"
  ...
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
Step 2: Use Fluent Bit to Push App Logs to CloudWatch
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/main/k8s-deployment-manifest-eks/deployment-mode/daemonset/fluent-bit/fluent-bit.yaml

Make sure your EKS worker node IAM role has this policy attached:
{
  "Effect": "Allow",
  "Action": [
  "logs:PutLogEvents",
    "logs:CreateLogStream",
    "logs:DescribeLogStreams"
  ],
  "Resource": "*"
}
2. Application Logging to CloudWatch
Your Node.js microservices already use console.log() – these are captured by Docker → container runtime → Fluent Bit → CloudWatch.

To improve structure:

Use a logging framework like winston or pino with JSON output for better searchability.

