plugin "aws" {
  enabled = true
  version = "0.24.3"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_resource_missing_tags" {
  enabled = true
  arguments = {
    required_tags = ["Automation", "Application", "Owner", "CostCenter", "Terraform", "Repository"]
  }
}

rule "terraform_required_providers" {
  enabled = false
}
rule "terraform_required_version" {
  enabled = false
}
