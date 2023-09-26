locals {
  version_parts    = regex("([0-9]+)\\.([0-9]+)\\.([0-9]+)", var.mongodb_version)
  mongo_major      = local.version_parts[0]
  mongo_minor      = local.version_parts[1]
  mongodb_hostname = "${local.env}-${local.name}-mongodb"
}

data "aws_ami_ids" "old_ubuntu" {
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "old_ubuntu" {
  filter {
    name   = "image-id"
    values = [element(data.aws_ami_ids.old_ubuntu.ids, length(data.aws_ami_ids.old_ubuntu.ids) - 1)]
  }
}

resource "random_pet" "mongodb_password" {
  length = 1
}

resource "aws_key_pair" "mongodb" {
  key_name   = "${local.env}-${local.name}-ec2-key"
  public_key = tls_private_key.mongodb.public_key_openssh
}

resource "tls_private_key" "mongodb" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "mongodb_private_key" {
  filename = "${path.module}/../../${local.env}-${local.name}-sshkey.pem"
  content  = tls_private_key.mongodb.private_key_pem
}

resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.old_ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.mongodb.name
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  key_name               = aws_key_pair.mongodb.key_name

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/mongodb_server_userdata.tpl", {
    mongodb_password = random_pet.mongodb_password.id
    mongodb_version  = var.mongodb_version
    mongodb_major    = local.mongo_major
    mongodb_minor    = local.mongo_minor
    hostname         = local.mongodb_hostname
    s3_bucket        = aws_s3_bucket.mongo_dumps.id
  })

  tags = merge(
    var.common_tags,
    {
      Name = local.mongodb_hostname
  })
}

data "aws_iam_policy_document" "mongodb" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "mongodb" {
  name        = "${local.env}-${local.name}-mongodb-ec2-policy"
  description = "Overly permissive policy for MongoDB EC2 instance"
  policy      = data.aws_iam_policy_document.mongodb.json

  tags = var.common_tags
}

resource "aws_iam_role" "mongodb" {
  name = "${local.env}-${local.name}-mongodb-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "mongodb" {
  role       = aws_iam_role.mongodb.name
  policy_arn = aws_iam_policy.mongodb.arn
}

resource "aws_iam_role_policy_attachment" "mongodb_ssm_connect" {
  role       = aws_iam_role.mongodb.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mongodb" {
  name = "${local.env}-${local.name}-mongodb-ec2-profile"
  role = aws_iam_role.mongodb.name

  tags = var.common_tags
}

resource "aws_security_group" "mongodb" {
  name        = "${local.env}-${local.name}-mongodb-ec2-sg"
  description = "Security group for MongoDB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
