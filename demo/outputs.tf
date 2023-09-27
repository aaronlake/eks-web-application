output "ami_id" {
  value       = module.eks_lab.ami_id
  description = "Old Ubuntu AMI ID"
}

output "ami_creation_date" {
  value       = module.eks_lab.ami_creation_date
  description = "Old Ubuntu AMI creation date"
}

output "instance_id" {
  value       = module.eks_lab.instance_id
  description = "MongoDB instance ID"
}

output "mongodb_password" {
  value       = module.eks_lab.mongodb_password
  description = "MongoDB password"
}

output "mongodb_connection_string" {
  value       = module.eks_lab.mongodb_connection_string
  description = "MongoDB connection string"
}

output "mongo_ssh_key_location" {
  value       = module.eks_lab.ssh_key_filename
  description = "MongoDB SSH command"
}

output "lb_hostname" {
  value       = module.eks_lab.lb_hostname
  description = "Demo app load balancer hostname"
}
