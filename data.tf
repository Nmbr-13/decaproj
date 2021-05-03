data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_id
}

data "template_file" "oidc_role_policy" {
  template = file("${path.module}/policies/iodc_assume_role_policy.json.tmpl")
  vars = {
    oidc_arn      = module.eks.oidc_provider_arn
    oidc_url      = module.eks.cluster_oidc_issuer_url
    k8s_namespace = var.k8s_ns
    sa_name       = var.serviceaccount_name
  }
}