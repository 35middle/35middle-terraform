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
  vpc_id = aws_vpc.main.id
  #   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  #   count                   = var.az_count
  count                   = length(var.availability_zones)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  }
}

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "${var.prefix}-route-table-public"
#   }
# }

resource "aws_route" "public" {
  #   route_table_id         = aws_route_table.public.id
  route_table_id = aws_vpc.main.main_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

resource "aws_route_table_association" "public" {
  #   count          = length(var.public_subnets)
  count     = length(var.availability_zones)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  #   route_table_id = aws_route_table.public.id
  route_table_id = aws_vpc.main.main_route_table_id


}

