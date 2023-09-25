module "eks_lab" {
  source = "../modules/eks-lab"

  mongodb_version = "5.0.10"
  # karpenter_version = "v0.30.0"

  common_tags = local.common_tags
}
