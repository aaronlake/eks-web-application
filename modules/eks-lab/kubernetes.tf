data "aws_eks_cluster_auth" "my_cluster" {
  name = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  host  = module.eks_cluster.cluster_endpoint
  token = data.aws_eks_cluster_auth.my_cluster.token

  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
}

provider "helm" {
  kubernetes {
    host  = module.eks_cluster.cluster_endpoint
    token = data.aws_eks_cluster_auth.my_cluster.token

    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  }

  registry {
    url      = "oci://public.ecr.aws"
    username = data.aws_ecrpublic_authorization_token.ecr_auth_token.user_name
    password = data.aws_ecrpublic_authorization_token.ecr_auth_token.password
  }
}

provider "kubectl" {
  host  = module.eks_cluster.cluster_endpoint
  token = data.aws_eks_cluster_auth.my_cluster.token

  load_config_file       = false
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
}
