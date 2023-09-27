output "ami_id" {
  value       = element(data.aws_ami_ids.old_ubuntu.ids, length(data.aws_ami_ids.old_ubuntu.ids) - 1)
  description = "Old Ubuntu AMI ID"
}

output "ami_creation_date" {
  value       = data.aws_ami.old_ubuntu.creation_date
  description = "Old Ubuntu AMI creation date"
}

output "instance_id" {
  value       = aws_instance.mongodb.id
  description = "MongoDB instance ID"
}

output "mongodb_password" {
  value       = random_pet.mongodb_password.id
  description = "MongoDB password"
}

output "mongodb_connection_string" {
  value       = "mongodb://admin:${random_pet.mongodb_password.id}@${aws_instance.mongodb.private_ip}:27017/?authSource=admin"
  description = "MongoDB connection string"
}

output "ssh_key_filename" {
  value       = local_file.mongodb_private_key.filename
  description = "MongoDB SSH command"
}

output "lb_hostname" {
  value       = kubernetes_service.demo_app.status[0].load_balancer[0].ingress[0].hostname
  description = "Demo app load balancer hostname"
}
