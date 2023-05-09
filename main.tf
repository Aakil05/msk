#create vpc for msk cluster
resource "aws_vpc" "msk_cluster_vpc" {
  cidr_block             = var.cidr_block
  enable_dns_hostnames   = true
}
#create SG for msk cluster
resource "aws_security_group" "msk_securitygroups" {
  name              = "msk_security_group"
  vpc_id            =  aws_vpc.msk_cluster_vpc.id

  ingress  {
    cidr_blocks     = var.msk_security_group_cidr_blocks
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
  }
  egress  {
    cidr_blocks     = var.msk_security_group_cidr_blocks
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
}
#create subnets 1 & 2 for msk cluster
resource "aws_subnet" "kafka_subnet_1" {
    vpc_id          = aws_vpc.msk_cluster_vpc.id
    cidr_block      = var.kafka_subnet_1_cidr
}
resource "aws_subnet" "kafka_subnet_2" {
    vpc_id          = aws_vpc.msk_cluster_vpc.id
    cidr_block      = var.kafka_subnet_2_cidr
}


#create aws MSK serverless cluster 
resource "aws_msk_serverless_cluster" "kafka_msk" {
  cluster_name        =   var.cluster_name
  tags = {
    kafka   =   "serverless"
  }
  vpc_config {
    subnet_ids         =   [aws_subnet.kafka_subnet_1.id,aws_subnet.kafka_subnet_2.id] 
    security_group_ids =   [aws_security_group.msk_securitygroups.id]
  }
  client_authentication {
    sasl {
      iam {
        enabled   =   var.iam_enabled
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
        Resource = var.iam_policy_resources
      },
    ]
  })
  tags = {
      Service    = "kafka"
    }
}

#create iam role
#resource "aws_iam_role" "msk_serverless_cluster_role" {
#  name               = "mskserverlessrole"
#  assume_role_policy = jsonencode({
#    Version          = "2012-10-17"
#    Statement        = [
#      {
#        Action       = "sts:AssumeRole"
#        Effect       = "Allow"
#        Principal    = {
#          Service    = var.iam_role_ec2_service
#        }
#      },
#      {
#        Action       = "sts:AssumeRole"
#        Effect       = "Allow"
#        Principal    = {
#          Service    = var.iam_role_eks_service
#        }
#      }
#    ]
#  })
#}

#data block to retrive existing role
data "aws_iam_role" "my_role" {
  name = "AvonTest-eks-node-group"
}

#attaching iam roles to the policy
 resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
 policy_arn     = aws_iam_policy.policies.arn
 role           = data.aws_iam_role.my_role.name
}
