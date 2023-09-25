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
  }
}
