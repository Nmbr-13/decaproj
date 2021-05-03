resource "aws_security_group" "worker_group_management" {
  name_prefix = "worker_group_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name                  = "decathlon-proj-vpc"
  cidr                  = var.vpc_cidr
  azs                   = data.aws_availability_zones.available.names
  private_subnets       = var.private_subnets_cidrs
  public_subnets        = var.public_subnets_cidrs
  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_dns_hostnames  = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "15.1.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.18"

  # eks nodes will be in private subnet => they will not be directly accessible from the internet:
  subnets                         = module.vpc.private_subnets
  cluster_create_timeout          = "1h"
  # will allow private endpoints to connect to kubernetes and join the cluster automatically:
  cluster_endpoint_private_access = true
  # tell eks module what vpc to join
  vpc_id                          = module.vpc.vpc_id

  enable_irsa = true

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.instance_type
      asg_desired_capacity          = "2"
      asg_max_size                  = "3"
      asg_min_size                  = "1"
      additional_security_group_ids = [aws_security_group.worker_group_management.id]
    },
  ]
  workers_group_defaults = {
    root_volume_type = "gp2"
  }
}

resource "aws_iam_policy" "s3_ro_policy" {
  name = "S3-RO-policy"
  path = "/"
  description = "Allow AWS EKS pods to get/list specific S3 bucket objects"
  policy = file("${path.module}/policies/s3_policy.json")
}

resource "aws_iam_role" "deca_eks_pods_s3_access_role" {
  name = "Decathlon-EKS-Pods-S3-access"
  path = "/"
  assume_role_policy = data.template_file.oidc_role_policy.rendered
  force_detach_policies = false

  tags = {
    ServiceAccountName = var.serviceaccount_name
    ServiceAccountNameSpace = var.k8s_ns
  }
  depends_on = [module.eks]
}

resource "aws_iam_role_policy_attachment" "s3_ro_policy_attachment" {
  policy_arn = aws_iam_policy.s3_ro_policy.arn
  role = aws_iam_role.deca_eks_pods_s3_access_role.name
}

resource "null_resource" "copy_kube_config" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "cp kubeconfig_decathlon-proj-eks-cluster ~/.kube/config"
  }
}

resource "kubernetes_service_account" "deca_serviceaccount" {
  depends_on = [null_resource.copy_kube_config]
  metadata {
    name      = var.serviceaccount_name
    namespace = var.k8s_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.deca_eks_pods_s3_access_role.arn
    }
  }
  automount_service_account_token = true
}

