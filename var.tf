#################################################_REGION_########################################################
variable "aws_region" {
  description = "aws_region"
  type        = string
  default     = "ap-south-1"
}


################################################_VPC_VAR_#######################################################
variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

#variable "vpc_cidr_ipv6" {
 #description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
 #type        = string
 #default     = "2406:da1a:618:4500::/56"
#}



variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}




#variable "public_subnet_cidrs_ipv6" {
 #type        = list(string)
 #description = "Public Subnet CIDR values"
 #default     = ["2406:da1a:618:4501::/64", "2406:da1a:618:4502::/64", "2406:da1a:618:4503::/64"]
#}

#variable "private_subnet_cidrs_ipv6" {
 #type        = list(string)
 #description = "Private Subnet CIDR values"
 #default     = ["2406:da1a:618:4504::/64", "2406:da1a:618:4505::/64", "2406:da1a:618:4506::/64"]
#}




##################################################_EKS_CLSUTER_VAR_##################################################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "test-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.22`)"
  type        = string
  default     = "1.27"
}

#variable "cluster_role" {
  #description = "IAM role for the cluster will be inherit from IAM module"
  #type        = string
  #default     = aws_iam_role.eks-cluster-role.arn
#}


variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = ["subnet-0e1716521624b0cff", "subnet-0efb37479ee10e802", "subnet-01c792123120c3ca0", "subnet-03aa410a1519fe55b", "subnet-03e3f810d5fec51d4", "subnet-033724b1ce73c24cc"]
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]."
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 30
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "oidc_provider_enabled" {
  type        = bool
  default     = false
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "eks_additional_security_group_ids" {
  type        = list(string)
  default     = ["sg-03aa22fcde896c169"]
  description = "EKS additional security group id"
}


variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned"
  type        = string
  default     = ""
}


variable "keyarn" {
  description = "ARN of the KMS key"
  type        = string
  default     = ""
}


variable "cluster_create_timeout" {
  type        = string
  default     = "30m"
  description = "Timeout value when creating the EKS cluster."
}

variable "cluster_delete_timeout" {
  type        = string
  default     = "15m"
  description = "Timeout value when deleting the EKS cluster."
}

variable "cluster_update_timeout" {
  type        = string
  default     = "60m"
  description = "Timeout value when updating the EKS cluster."
}


variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.27.1-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.12.6-eksbuild.2"
    },
    #{
     # name    = "coredns"
      #version = "v1.10.1-eksbuild.1"
    #},
    #{
      # name    = "aws-ebs-csi-driver"
      #version = "v1.19.0-eksbuild.2"
    #}
  ]
}



################################################_EKS_NODE_GROUP_VAR_#################################################

variable "node_iam_role" {
  description = "Node arn to perform the operations and fetch parameters"
  type        = string
  default     = "test_node_group"
}
variable "min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 2
}
variable "max_size" {
  description = "autoscalling parameters max numbers nodes required to run CPS application"
  type        = number
  default     = 2
}
variable "desired_size" {
  description = "exact number of node/servers require to run CPS"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "exact number of node/servers require to run CPS"
  type        = number
  default     = 20
}

variable "ami_type" {
  description = "Optimised amiid for EKS cluster please choose default option"
  type        = string
  default     = "AL2_x86_64"
}
variable "release_version" {
  description = "release version for EKS cluster nodes please choose default option"
  type        = string
  default     = "1.26"
}
variable "nodeversion" {
  description = "Version for EKS cluster nodes please choose default option"
  type        = string
  default     = null
}
variable "capacity_type" {
  description = "Please choose the default capacity"
  type        = string
  default     = "ON_DEMAND"
}
variable "force_update_version" {
  description = "Please choose the default option"
  type        = bool
  default     = false
}
variable "instance_types" {
  description = "Please choose the instance type to run CPS, default recommended is t3.medium"
  type        = list(string)
  default     = ["t3.medium"]
}








#################################################_IAM_POLICY_VAR_#####################################################
variable "cluster_encryption_policy_description" {
  description = "Description of the cluster encryption policy created"
  type        = string
  default     = "Cluster encryption policy to allow cluster role to utilize CMK provided"
}

variable "cluster_encryption_policy_path" {
  description = "Cluster encryption policy path"
  type        = string
  default     = null
}

