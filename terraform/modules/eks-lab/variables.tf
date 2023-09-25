variable "common_tags" {
  type        = map(string)
  description = "Common variables for all modules"
}

variable "mongodb_version" {
  type        = string
  description = "Version of MongoDB to install"
}
