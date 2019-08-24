provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "awsbook-terraform-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "awsbook-terraform-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "awsbook-terraform-internet-gateway"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "awsbook-terraform-public-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "awsbook-terraform-sg"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.key_path)
}

resource "aws_instance" "webserver" {
  ami = "ami-04b2d1589ab1d972c"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  availability_zone = "ap-northeast-1c"
  associate_public_ip_address = true
  private_ip = "10.0.1.10"

  tags = {
    Name = "awsbook-terraform-webserver"
  }

  subnet_id = aws_subnet.public.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "awsbook-terraform-private-subnet"
  }
}

resource "aws_instance" "dbserver" {
  ami = "ami-04b2d1589ab1d972c"
  instance_type = "t2.micro"
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = ["${aws_security_group.dbsg.id}"]
  availability_zone = "ap-northeast-1c"
  private_ip = "10.0.2.10"

  tags = {
    Name = "awsbook-terraform-dbserver"
  }

  subnet_id = aws_subnet.private.id
}

resource "aws_security_group" "dbsg" {
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 3306
    to_port = 3306
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "awsbook-terraform-dbsg"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "natr" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "awsbook-terraform-nat-route-table"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.natr.id
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id
  depends_on = ["aws_internet_gateway.gw"]

  tags = {
    Name = "awsbook-terraform-nat-gw"
  }
}
