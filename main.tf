provider "aws" {
  region = "ap-southeast-2"

}

resource "aws_vpc" "iv_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-iv-vpc"
    }
}

module "iv-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.iv_vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  default_route_table_id = aws_vpc.iv_vpc.default_route_table_id
}

module "iv-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.iv_vpc.id
  my_ip = var.my_ip
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.iv-subnet.subnet.id
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
}