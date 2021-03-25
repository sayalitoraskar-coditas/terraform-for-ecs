resource "aws_vpc" "private-net-for-ecs" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "private-net-for-ecs"
    }
}

resource "aws_subnet" "sub-1" {
    availability_zone = "ap-south-1a"
    cidr_block = "10.0.0.0/20"
    map_public_ip_on_launch = "true"
    vpc_id = aws_vpc.private-net-for-ecs.id
    tags = {
        Name = "sub-1"
    }
}
resource "aws_subnet" "sub-2" {
    availability_zone = "ap-south-1b"
    cidr_block = "10.0.16.0/20"
    map_public_ip_on_launch = "true"
    vpc_id = aws_vpc.private-net-for-ecs.id
    tags = {
        Name = "sub-2"
    }
}
resource "aws_subnet" "sub-3" {
    availability_zone = "ap-south-1c"
    cidr_block = "10.0.32.0/20"
    map_public_ip_on_launch = "true"
    vpc_id = aws_vpc.private-net-for-ecs.id
    tags = {
        Name = "sub-3"
    }
}

resource "aws_internet_gateway" "ig-for-ecs" {
    vpc_id = aws_vpc.private-net-for-ecs.id
    tags = {
        Name = "ig-for-ecs"
    }
}

resource "aws_route_table" "new-rt" {
    vpc_id = aws_vpc.private-net-for-ecs.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig-for-ecs.id
    }
    tags = {
        Name = "new-rt"
    }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.new-rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.new-rt.id
}

resource "aws_route_table_association" "a3" {
  subnet_id      = aws_subnet.sub-3.id
  route_table_id = aws_route_table.new-rt.id
}

resource "aws_security_group" "secgroup-for-ecs" {
    name = "secgroup-for-ecs"
    vpc_id = aws_vpc.private-net-for-ecs.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 81
        to_port = 81
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "secgroup-for-ecs"
    }
}

resource "tls_private_key" "ecs_keypair" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "ecs_keypair" {
  key_name   = var.key_pair
  public_key = tls_private_key.ecs_keypair.public_key_openssh
}

resource "local_file" "local_ssh_private_key" {
  content         = tls_private_key.ecs_keypair.private_key_pem
  filename        = "ssh-key-private.pem"
  file_permission = "0777"
}