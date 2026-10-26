resource "aws_security_group_rule" "jenkins_to_eks_api" {
  description              = "Allow Jenkins to reach the EKS API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.jenkins.id
}
