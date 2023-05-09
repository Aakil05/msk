#vcp ID
#variable "vpc_id" {
# default = [aws_vpc.msk_cluster_vpc.id]
#}

#vpc cidr block
variable "cidr_block" {
  default = "10.0.0.0/16"
}

#subnet ID
#variable "subnet_ids" {
# default =  [aws_subnet.kafka_subnet_1.id,aws_subnet.kafka_subnet_2.id]
#}

#subnet1 cidr block
variable "kafka_subnet_1_cidr" {
  default     = "10.0.1.0/24"
}

#subnet2 cidr block
variable "kafka_subnet_2_cidr" {
  default     = "10.0.2.0/24"
}

#security group ID
#variable "security_group_ids" {
# default = [aws_security_group.msk_securitygroups.id]
#}

#security group ingress port from and to
#variable "msk_security_group_ingress_ports" {
# default     = [9092]
#}

#security group egress port from and to
#variable "msk_security_group_egress_ports" {
# description = "List of egress ports to open on the MSK security group"
#type        = list(number)
#default     = [0]
#}

#security group cidr blocks
variable "msk_security_group_cidr_blocks" {
  description = "List of CIDR blocks to allow traffic to/from the MSK security group"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

#cluster name msk serverless cluster
variable "cluster_name" {
  description = "The name of the MSK serverless cluster."
  default = "mskserverlesscluster"
}

#cluster iam enabled
variable "iam_enabled" {
  default = true
}

#variable "tags" {
# default = {
#  kafka = "serverless"
#}
#}

variable "iam_policy_name" {
  default = "terraform_msk_access"
}

#variable "iam_role_name" {
# default = "mskserverlessrole"
#}

variable "iam_role_ec2_service" {
  default = "ec2.amazonaws.com"
}

variable "iam_role_eks_service" {
  default = "eks.amazonaws.com"
}

#variable "iam_policy_actions" {
# default = [
#  "kafka-cluster:*Topic*",
# "kafka-cluster:AlterGroup",
#"kafka-cluster:ReadData",
#"kafka-cluster:DescribeCluster",
#"kafka-cluster:AlterCluster",
#"kafka-cluster:DescribeGroup",
#"kafka-cluster:Connect",
#"kafka-cluster:WriteData"
#]
#}

#iam policy resource
variable "iam_policy_resources" {
  default = ["*"]
}

#variable "iam_policy_tags" {
# default = {
#  Service = "kafka"
#}
#}

#variable "iam_role_policy_attachment_role_name" {
# default = aws_iam_role.msk_serverless_cluster_role.name
#}

#variable "policy_arn" {
# type = string
#}

#variable "role_name" {
# type = string
#}
