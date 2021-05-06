terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.33.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.1.0"
    }
  }
  backend "s3" {
    bucket = "decathlon-proj-state"
    key = "test-proj/terraform.tfstate"
    region = "eu-central-1"
  }
}
provider "aws" {
  region = var.region
}

provider "kubernetes" {
//  config_path = "~/.kube/config"
  config_context          = data.aws_eks_cluster.cluster.arn
  host                    = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                   = data.aws_eks_cluster_auth.cluster_auth.token
////  exec {
////    api_version = "client.authentication.k8s.io/v1alpha1"
////    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
////    command = "awsv2"
////  }
}