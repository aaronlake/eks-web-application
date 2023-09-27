/*
* ## EKS Demo Lab
*
* This demo environment is set up with a few significant flaws that should not
* be replicated in production environments. These flaws are intentional, except
* for the ones that weren't ;).
*
* The sole purpose of this demo environment is to identify flaws by using third
* party tools to identify "opportunities for improvement." Don't use this as an
* example of my work, unless you're looking for a cautionary tale.
*
* ### Flaws
* 1. An outdated version of Ubuntu and MongoDB are used for the MongoDB server
* 2. Logs are directly written to a public S3 bucket
* 3. IMDSv2 is not enabled
* 4. The EKS cluster is not configured to use a private endpoint
* 5. MongoDB instance EBS volumes are not encrypted
* 6. The MongoDB instance is not configured to use TLS
* 7. The MongoDB instance profile has overly permissive IAM permissions
* 8. ECS images are not scanned for vulnerabilities
* 9. And more!
*
*/
terraform {
  required_version = ">=1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.17.0"
    }

    time = {
      source  = "hashicorp/time"
      version = ">=0.9.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
