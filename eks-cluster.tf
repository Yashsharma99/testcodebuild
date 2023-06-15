resource "aws_eks_cluster" "test_eks_cluster" {
  enabled_cluster_log_types = var.enabled_cluster_log_types
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks-cluster-role.arn
  version                   = var.cluster_version
  

  vpc_config {
   security_group_ids      = ["${aws_security_group.eks-cluster.id}"]
   subnet_ids                            = concat(aws_subnet.public_subnets[*].id, aws_subnet.private_subnets[*].id)
#["${aws_subnet.public_subnets.*.id}", "${aws_subnet.private_subnets.*.id}"]
   endpoint_private_access               = var.cluster_endpoint_private_access
   endpoint_public_access                = var.cluster_endpoint_public_access
   public_access_cidrs     = var.public_access_cidrs
  }

 kubernetes_network_config {
    ip_family         = var.cluster_ip_family
    #service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

 encryption_config {
    provider {
      key_arn= aws_kms_key.kms.arn
      }
    resources =["secrets"]
  }

 timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
    update = var.cluster_update_timeout
  }


 depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cloudwatch_log_group

  ]

 tags = {
    Environment = "devops"
  }

}






#--------------------------------------
# Enabling IAM Role for Service Account
#--------------------------------------

data "tls_certificate" "ekstls" {
  url = aws_eks_cluster.test_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eksopidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.ekstls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.test_eks_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eksdoc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eksopidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eksopidc.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "iam_roles_for_service_accounts" {
  assume_role_policy = data.aws_iam_policy_document.eksdoc_assume_role_policy.json
  name               = "Role_for_service_accounts"
}

resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.test_eks_cluster.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
}








resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  # ... potentially other configuration ...
}
