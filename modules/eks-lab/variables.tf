variable "common_tags" {
  type        = map(string)
  description = "Common variables for all modules"
}

variable "mongodb_version" {
  type        = string
  description = "Version of MongoDB to install"
}

# variable "karpenter_version" {
#   description = "https://gallery.ecr.aws/karpenter/karpenter"
#   type        = string
# }
