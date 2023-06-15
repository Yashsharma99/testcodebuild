resource "aws_security_group" "Test_SG" {
  name = "CLuster_SG"
  description= "Allow inbound efs traffic from ECS tasks"
  vpc_id = aws_vpc.TestVPC.id
  ingress {
    cidr_blocks = ["212.247.19.62/32"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["212.247.19.62/32"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
    }

  ingress {
    cidr_blocks = ["212.247.19.62/32"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}


################_Create EKS master security group_########################

resource "aws_security_group" "eks-cluster" {
  name        = "eks-cluster-SG"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.TestVPC.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 
 }
}

resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["212.247.19.62/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks_nodes.id}"
  to_port                  = 443
  type                     = "ingress"
}














####_SG_FOR_EKS_NODE_#########

resource "aws_security_group" "eks_nodes" {
  name        = "eks-worker-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.TestVPC.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_cluster_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
