# Find the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a keypair in AWS to use with the instance with a pre-generated keypair
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

# Create a security group to manage server connections
resource "aws_security_group" "dylanmtaylor" {

  name        = "dylanmtaylor"
  description = "Connections allowed for dylanmtaylor instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS  from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dylanmtaylor"
  }
}

# Create a new VPC for the instance
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

# Attach the VPC to a new internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table for traffic to go over the internet
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate the subnet to that route table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Create a new subnet for the instance
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block        = "10.0.1.0/24"
}

# Creates an IAM profile that allows SSM connections to the machine
resource "aws_iam_instance_profile" "ssm" {
  name = "dylanmtaylor_ssm_profile"
  role = aws_iam_role.ssm.name
}


resource "aws_iam_role" "ssm" {
  name                = "dylanmtaylor_ssm_role"
  path                = "/"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  assume_role_policy  = <<EOF
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

# Create the instance itself
resource "aws_instance" "dylanmtaylor" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = var.instance_flavor
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = ["${aws_security_group.dylanmtaylor.id}"]
  iam_instance_profile        = aws_iam_instance_profile.ssm.id
  subnet_id                   = "${aws_subnet.main.id}"

  user_data = file("${path.module}/dylanmtaylor_cloudinit.yml.tpl")

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = false
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "dylanmtaylor"
  }
}

resource "aws_eip" "dylanmtaylor" {
  instance = aws_instance.dylanmtaylor.id
  vpc = true

  tags = {
    Name = "dylanmtaylor"
  }
}
