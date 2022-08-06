resource "aws_subnet" "iv-subnet-1" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-iv-subnet-1"
  }
}

resource "aws_internet_gateway" "iv_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-iv-igw"
  }
}

resource "aws_default_route_table" "iv_default_route_table" {
  default_route_table_id = var.default_route_table_id

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
