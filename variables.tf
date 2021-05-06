variable "region" {
  default = "eu-central-1"
  description = "AWS region"
}

variable "cluster_name" {
  default = "decathlon-proj-eks-cluster"
}



variable "vpc_cidr" {
  default = "13.0.0.0/16"
}

variable "private_subnets_cidrs" {
  type = list(string)
  default = ["13.0.1.0/24", "13.0.2.0/24"]
}

variable "public_subnets_cidrs" {
  type = list(string)
  default = ["13.0.3.0/24", "13.0.4.0/24"]
}

variable "instance_type" {
  default = "t2.small"
}


variable "k8s_ns" {
  default = "default"
}

variable "serviceaccount_name" {
  default = "my-serviceaccount"
}