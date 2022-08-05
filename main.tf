provider "aws" {
  region = "ap-southeast-2"

}

variable "vpc_cidr_block" {}

variable "subnet_cidr_block" {}

variable "avail_zone" {}

variable "env_prefix" {}

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

resource "aws_route_table" "iv_route_table" {
  vpc_id = aws_vpc.iv_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.iv_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-iv-route-table"
  }
}

resource "aws_internet_gateway" "iv_igw" {
  vpc_id = aws_vpc.iv_vpc.id
  tags = {
    Name = "${var.env_prefix}-iv-igw"
  }
}

resource "aws_route_table_association" "iv_rt_assoc" {
  route_table_id = aws_route_table.iv_route_table.id
  subnet_id = aws_subnet.iv-subnet-1.id
}