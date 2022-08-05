provider "aws" {
  region = "ap-southeast-2"

}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "avail_zone" {}

variable "env_prefix" {}

variable "my_ip" {}

variable "instance_type" {}

resource "aws_vpc" "iv_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-iv-vpc"
    }
}

resource "aws_subnet" "iv-subnet-1" {
  vpc_id = aws_vpc.iv_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-iv-subnet-1"
  }
}

resource "aws_internet_gateway" "iv_igw" {
  vpc_id = aws_vpc.iv_vpc.id
  tags = {
    Name = "${var.env_prefix}-iv-igw"
  }
}

resource "aws_default_route_table" "iv_default_route_table" {
  default_route_table_id = aws_vpc.iv_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iv_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-iv-default-route-table"
  }
}

resource "aws_route_table_association" "iv_rt_assoc" {
  route_table_id = aws_default_route_table.iv_default_route_table.id
  subnet_id = aws_subnet.iv-subnet-1.id
}

resource "aws_security_group" "iv_security_group" {
  name = "${var.env_prefix}-iv-security-group"
  vpc_id = aws_vpc.iv_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-iv-security-group"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest_amazon_linux_image.id
}

resource "aws_instance" "iv_server" {
  ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.iv_security_group.id]
  subnet_id = aws_subnet.iv-subnet-1.id
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "server-key-pair"

  tags = {
    Name = "${var.env_prefix}-iv-server"
  }
}