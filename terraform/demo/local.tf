locals {
  common_tags = {
    "Automation"  = "Terraform"
    "Environment" = "Demo"
    "Application" = "EKS Lab"
    "Owner"       = "n/a"
    "CostCenter"  = "n/a"
    "Terraform"   = "True"
    "Repository"  = "aaronlake/eks-web-application"
    "name"        = "ekslab"
  }
}
