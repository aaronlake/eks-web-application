module "eks_lab" {
  source = "../modules/eks-lab"

  mongodb_version = "5.0.10"

  common_tags = local.common_tags
}
