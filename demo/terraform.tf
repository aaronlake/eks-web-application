provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = ">=1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.17.0"
    }
  }

  backend "s3" {
    bucket = "eks-lab-terraform-state-20230922"
    key    = "prod/terraform.tfstate"
    region = "us-east-2"
  }
}
