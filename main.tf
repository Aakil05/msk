#provisioning provider aws
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
#existing eks cluster
data "aws_eks_cluster" "example" {
  name = var.eks_cluster_name
}
#vpc and subnets of the eks cluster
data "aws_vpc" "vpc_name" {
  id = data.aws_eks_cluster.example.vpc_config[0].vpc_id
}
data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_name.id]
  }
}
data "aws_subnet" "eks_subnets_data" {
  count    = 2
  id       = element(tolist(data.aws_subnets.eks_subnets.ids), count.index)
  depends_on = [data.aws_subnets.eks_subnets]
}
#Security Group for MSK cluster
resource "aws_security_group" "example" {
  name = join("-", [var.cluster_name, "sg"])
  vpc_id = data.aws_vpc.vpc_name.id
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "msk_serverless-sg"
  }
}
#MSK Serverless cluster 
resource "aws_msk_serverless_cluster" "kafka_msk" {
  cluster_name        =   var.cluster_name
  tags = {
   eks_cluster = data.aws_eks_cluster.example.name
  }
  vpc_config {
    #subnet_ids =  values(data.aws_subnet.eks_subnets_data)[*].id
    subnet_ids = [data.aws_subnet.eks_subnets_data[0].id,data.aws_subnet.eks_subnets_data[1].id]
    security_group_ids =   [aws_security_group.example.id]
  }
  client_authentication {
    sasl {
      iam {
        enabled   =   true
      }
    }
  }
}
#create iam policy like msk_access
#iam policy 
resource "aws_iam_policy" "policies" {
  name           = var.iam_policy_name
  policy         = jsonencode({
    Version      = "2012-10-17"
    Statement    = [
     {
        Effect   = "Allow"
        Action   = [
            "kafka-cluster:*Topic*",
            "kafka-cluster:AlterGroup",
            "kafka-cluster:ReadData",
            "kafka-cluster:DescribeCluster",
            "kafka-cluster:AlterCluster",
            "kafka-cluster:DescribeGroup",
            "kafka-cluster:Connect",
            "kafka-cluster:WriteData"
        ]
        Resource = "*"
      },
    ]
  })
  tags = {
      Service    = "kafka"
    }
}
#Node group of eks cluster
data "aws_eks_node_groups" "example" {
  cluster_name = data.aws_eks_cluster.example.name
}
data "aws_eks_node_group" "example" {
  for_each = data.aws_eks_node_groups.example.names
  cluster_name    = data.aws_eks_cluster.example.name
  node_group_name = each.value
}
#IAM role of the Node group
data "aws_iam_role" "my_role" {
  for_each = data.aws_eks_node_group.example
  name     = split("/", each.value.node_role_arn)[1]
}
#IAM Role Policy attachment
resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each    = data.aws_iam_role.my_role
  role        = each.value.name
  policy_arn  = aws_iam_policy.policies.arn
}
