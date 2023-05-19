variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  default = "ap-south-1"
}

variable "eks_cluster_name" {
  type = string
  default = "eks-cluster"
}

#cluster name msk serverless cluster
variable "cluster_name" {
  default = "kafka-serverless-cluster"
}

variable "iam_policy_name" {
  default = "msk_access_terraform"
}


