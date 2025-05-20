pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    AWS_ACCOUNT_ID = '123456789012'
    ECR_PATIENT_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/patient-service"
    ECR_APPT_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/appointment-service"
    KUBECONFIG = credentials('EKS_KUBECONFIG') // If using kubeconfig stored as secret file
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init & Lint') {
      dir('terraform') {
        steps {
          sh 'terraform fmt -check'
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Plan') {
      dir('terraform') {
        steps {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'AWS_CREDENTIALS'
          ]]) {
            sh 'terraform plan -out=tfplan'
          }
        }
      }
    }

    stage('Terraform Apply') {
      dir('terraform') {
        steps {
          input message: 'Apply Terraform changes?'
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }

    stage('Build & Push Docker Images') {
      parallel {
        stage('Patient Service') {
          steps {
            dir('patient-service') {
              script {
                sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_PATIENT_REPO"
                sh "docker build -t patient-service ."
                sh "docker tag patient-service:latest $ECR_PATIENT_REPO:latest"
                sh "docker push $ECR_PATIENT_REPO:latest"
              }
            }
          }
        }

        stage('Appointment Service') {
          steps {
            dir('appointment-service') {
              script {
                sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_APPT_REPO"
                sh "docker build -t appointment-service ."
                sh "docker tag appointment-service:latest $ECR_APPT_REPO:latest"
                sh "docker push $ECR_APPT_REPO:latest"
              }
            }
          }
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'AWS_CREDENTIALS'
        ]]) {
          sh "aws eks update-kubeconfig --region $AWS_REGION --name hackathon-cluster"

          // Apply manifests
          sh "kubectl apply -f k8s/patient-service/"
          sh "kubectl apply -f k8s/appointment-service/"
          sh "kubectl apply -f k8s/ingress.yaml"
        }
      }
    }
  }

  post {
    success {
      echo '✅ Pipeline executed successfully!'
    }
    failure {
      echo '❌ Pipeline failed.'
    }
  }
}
