terraform {
  backend "s3" {}
  required_version = "= 1.1.7"

  required_providers {
    aws = "= 4.2.0"
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  acc_id              = "${data.aws_caller_identity.current.account_id}"
  private_subnet_ids  = "${data.terraform_remote_state.network.outputs.vpc["private_subnet_ids"]}"
  public_subnet_ids   = "${data.terraform_remote_state.network.outputs.vpc["public_subnet_ids"]}"
  vpc_id              =  "${data.terraform_remote_state.network.outputs.vpc["id"]}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.product}-tf-states-${local.acc_id}"
    key    = "${var.product}-${var.project}-${local.acc_id}/${var.deployment_identifier}/network/terraform.tfstate"
    region = var.backend_region
  }
}


#AMI
data "aws_ami" "sftp-ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


#IAM
resource "aws_iam_role" "sftp" {
  name = format("%s-%s-%s", var.product, var.deployment_identifier, "sftp")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# SSM policy attachment
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.sftp.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "sftp" {
  name = format("%s-%s-%s", var.product, var.deployment_identifier, "sftp")
  role = aws_iam_role.sftp.id
}
##################


#SG
resource "aws_security_group" "sftp" {
  name        = format("%s-%s-%s-%s", var.product, var.deployment_identifier, "sftp", "sg")
  description = format("%s sftp host security group", var.deployment_identifier)
  vpc_id      = local.vpc_id[0]
  tags = merge(
    var.tags,
    { 
      "Name" = "${var.product}-${var.deployment_identifier}-sftp-sg" 
    },
  )
}

resource "aws_security_group_rule" "egress" {
  type      = "egress"
  protocol  = "-1"
  to_port   = 0
  from_port = 0

  description       = "Allow all traffic out to any destination"
  security_group_id = aws_security_group.sftp.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.sftp.id
  cidr_blocks       = var.sftp_ingress_cidrs
}

data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.sh")

  vars = {
    sftp_home               = var.sftp_home
    sftp_root_broadvine     = "${var.sftp_home}/${var.sftp_root_broadvine_dir}"
    sftp_root_mdo           = "${var.sftp_home}/${var.sftp_root_mdo_dir}"
    sftp_user               = var.sftp_user
    sftp_pass               = var.sftp_pass
    mdo_user                = var.mdo_user
    mdo_pass                = var.mdo_pass
  }
}



resource "aws_instance" "sftp" {
  ami                  = data.aws_ami.sftp-ami.id
  key_name             = var.key_name
  instance_type        = var.sftp_instance_type
  subnet_id            =  local.public_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.sftp.name

  vpc_security_group_ids      = [aws_security_group.sftp.id]
  associate_public_ip_address = var.associate_public_ip_address
  user_data_base64            = base64encode(data.template_file.userdata.rendered)

  root_block_device {
    volume_size = var.volume_size
  }

  tags = merge(
    var.tags,
    { 
      "Name" = "${var.product}-${var.deployment_identifier}-sftp" 
    },
  )
}