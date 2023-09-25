module "deny_all_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = "${local.env}-cluster-EKS-IRSA-DenyAll"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AWSDenyAll"
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      namespace_service_accounts = []
    }
  }

  tags = var.common_tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = "${local.env}-cluster-EKS-IRSA-VPC-CNI"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.common_tags
}
