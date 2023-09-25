data "aws_caller_identity" "current" {}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = "${local.env}-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  control_plane_subnet_ids       = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  cluster_enabled_log_types = [] # Disable logging
  cluster_encryption_config = {} # Disable secrets encryption

  tags = merge(var.common_tags, {
    "karpenter.sh/discovery" = "${local.env}-cluster"
  })

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }

  # Fargate profiles use the cluster's primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  # fargate_profiles = {
  #   kube-system = {
  #     selectors = [
  #       { namespace = "kube-system" }
  #     ]
  #   }
  #   karpenter = {
  #     selectors = [
  #       { namespace = "karpenter" }
  #     ]
  #   }
  # }

  cluster_addons = {
    kube-proxy = {
      most_recent = true

      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.deny_all_irsa.iam_role_arn
    }

    vpc-cni = {
      most_recent = true

      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.vpc_cni_irsa.iam_role_arn
    }

    coredns = {
      most_recent = true

      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.deny_all_irsa.iam_role_arn

      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  manage_aws_auth_configmap = true
  # aws_auth_roles = [
  #   {
  #     rolearn  = module.karpenter.role_arn
  #     username = "system:node:{{EC2PrivateDNSName}}"
  #     groups   = ["system:nodes", "system:bootstrappers"]
  #   },
  # ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      username = "root"
      groups   = ["system:masters"]
    }
  ]
}
