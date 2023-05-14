# use data source to get all avalablility zones in region
#data "aws_availability_zones" "available_zones" {}

variable "eks_cluster_name" {
  type = string
  default = "eks-cluster"
}

#existing eks cluster
data "aws_eks_cluster" "example" {
  name = var.eks_cluster_name
}

#fetching vpc of the eks cluster
#data "aws_vpc" "vpc_name" {
#  id = data.aws_eks_cluster.example.vpc_config[0].vpc_id
#}

#fetching subnet1 based on availability zone from the vpc
#data "aws_subnet" "example_1" {
#  vpc_id            = data.aws_vpc.vpc_name.id
#  availability_zone = data.aws_availability_zones.available_zones.names[0]
#}

#fetching subnet2 based on availability zone from the vpc
#data "aws_subnet" "example_2" {
#  vpc_id            = data.aws_vpc.vpc_name.id
#  availability_zone = data.aws_availability_zones.available_zones.names[1]
#}

#fetching the security group which is owned by the eks cluster
#data "aws_security_group" "example" {
#  vpc_id            = data.aws_vpc.vpc_name.id
#  tags = {
#    "kubernetes.io/cluster/${data.aws_eks_cluster.example.name}" = "owned"
#  }
#}

#create aws MSK serverless cluster 
#resource "aws_msk_serverless_cluster" "kafka_msk" {
#  cluster_name        =   var.cluster_name
#  tags = {
#    eks_cluster = data.aws_eks_cluster.example.name
#  }
#  vpc_config {
#    subnet_ids         =   [data.aws_subnet.example_1.id,data.aws_subnet.example_2.id]
#    security_group_ids =   [data.aws_security_group.example.id]
#  }
#  client_authentication {
#    sasl {
#      iam {
#        enabled   =   var.iam_enabled
#      }
#    }
#  }
#}

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
####################
#### retriving role using node group name###
#variable "node_group_name" {
#    default = "nodegrp"
#}

#data "aws_eks_node_group" "example" {
#  cluster_name    = data.aws_eks_cluster.example.name
#  node_group_name = var.node_group_name
#}

#data "aws_iam_role" "my_role" {
#  name = split("/", data.aws_eks_node_group.example.node_role_arn)[1]
#}
#  output "my_role_name" {
#  value = data.aws_iam_role.my_role.name
#}

#resource "aws_iam_role_policy_attachment" "policy_attachment" {
#  role = data.aws_iam_role.my_role.name
#  policy_arn = aws_iam_policy.policies.arn
#}
#### retriving role using node group name###
##########################

#Retrieve the node group names using the AWS CLI
#Iterate over each node group and retrieve the IAM role ARN
#resource "null_resource" "get_eks_node_group_roles" {
#  provisioner "local-exec" {
#    command = <<EOT
       

#      node_group_names=$(aws eks list-nodegroups --cluster-name ${data.aws_eks_cluster.example.name} --output text --query 'nodegroups[*]')

#      for node_group_name in $node_group_names; do
#        node_group_role=$(aws eks describe-nodegroup --cluster-name ${data.aws_eks_cluster.example.name} --nodegroup-name $node_group_name --output text --query 'nodegroup.nodeRole')
#        echo "Node Group: $node_group_name, Role: $node_group_role"
#      done
#    EOT
#  }

#  depends_on = [data.aws_eks_cluster.example]
#}
#data "aws_eks_node_group" "example" {
#  cluster_name = data.aws_eks_cluster.example.name
#}
data "aws_eks_node_group" "example" {
  for_each = data.aws_eks_cluster.example.node_groups
  cluster_name = data.aws_eks_cluster.example.name
  node_group_name = each.key
}

data "aws_iam_role" "example" {
  name = data.aws_eks_node_group.example.node_group[0].remote_access[0].ec2_ssh_key[0].key_pair_name
}

#attaching iam roles to the policy
 resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
 policy_arn     = data.aws_iam_policy.policies.arn
 role           = data.aws_iam_role.example.name
}



##########
#by using output we get name and number of nodes in the eks cluster
#data "aws_eks_node_group" "example" {
#  cluster_name = data.aws_eks_cluster.example.name
#}


#resource "aws_iam_role_policy_attachment" "policy_attachment"{
#  role = data.aws_iam_role.example.name
#  policy_arn = aws_iam_policy.policies.arn
#}

#output "eks_node_groups" {
#  value = data.aws_eks_node_groups.node_groups
#}

#data "aws_iam_roles" "roles" {
#  for_each = data.aws_eks_node_groups.node_groups.*.node_role_arn
#}

#resource "aws_iam_role_policy_attachment" "policy_attachment" {
#  for_each = data.aws_iam_roles.roles.*
#  role = each.value.arn
#  policy_arn = aws_iam_policy.policies.arn
#}

