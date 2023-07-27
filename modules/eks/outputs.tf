output "cluster_endpoint" {
  value = var.cluster_endpoint_private_access
}

output "public_cluster_endpoint" {
  value = var.cluster_endpoint_public_access
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority
}

