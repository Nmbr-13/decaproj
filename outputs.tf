output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value = module.eks.cluster_endpoint
}

output "cluster_sg_id" {
  description = "Security groups IDs attached to cluster control plane"
  value = module.eks.cluster_security_group_id
}

//output "kubectl_config" {
//  # can be used later to pass it to kubernetes module to spin up deployments, pods, services
//  description = "kubectl config file"
//  value = module.eks.kubeconfig
//}

//output "config_map_aws_auth" {
//  description = "A k8s configuration to authenticate to this EKS cluster"
//  value = module.eks.config_map_aws_auth
//}

output "deca_eks_pods_s3_access_role_arn" {
  value = aws_iam_role.deca_eks_pods_s3_access_role.arn
}