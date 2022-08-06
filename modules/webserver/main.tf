resource "aws_security_group" "iv_security_group" {
  name = "${var.env_prefix}-iv-security-group"
  vpc_id = var.vpc_id

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
    values = [var.image_name]
  }
}


resource "aws_key_pair" "ssh_key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "iv_server" {
  ami = data.aws_ami.latest_amazon_linux_image.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.iv_security_group.id]
  subnet_id = var.subnet_id
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  user_data = file("${path.module}/entry_script.sh")

  tags = {
    Name = "${var.env_prefix}-iv-server"
  }
}