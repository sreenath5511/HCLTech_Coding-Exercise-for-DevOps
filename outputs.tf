output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_urls" {
  value = {
    patient    = aws_ecr_repository.patient_service.repository_url
    appointment = aws_ecr_repository.appointment_service.repository_url
  }
}
