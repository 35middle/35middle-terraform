resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}--igw"
  }
}

resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # count                   = length(var.availability_zones)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count      = var.az_count
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  # availability_zone = data.aws_availability_zones.available.names[count.index]
  availability_zone = element(var.availability_zones, count.index)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route" "public" {
  #   route_table_id         = aws_route_table.public.id
  route_table_id = aws_vpc.main.main_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id



}

resource "aws_eip" "gw" {
  count = var.az_count
  vpc   = true
  # depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
}



resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  # count     = length(var.availability_zones)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  #   route_table_id = aws_route_table.public.id
  route_table_id = aws_vpc.main.main_route_table_id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


