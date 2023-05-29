terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "ass-vpc" {
  cidr_block = "10.0.0.0/16"
}


# Create an internet gateway
resource "aws_internet_gateway" "ass-ig" {
  vpc_id = aws_vpc.ass-vpc.id

  tags = {
    Name = "gateway1"
  }
}


# Create a subnet
resource "aws_subnet" "ass-subnet" {
  vpc_id     = aws_vpc.ass-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone= "ap-south-1a"

  tags = {
    Name = "subnet1"
  }
}


# Create a custom route table
resource "aws_route_table" "ass-rt" {
  vpc_id = aws_vpc.ass-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ass-ig.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.ass-ig.id
  }

  tags = {
    Name = "rt1"
  }
}

# associate subnet with the route table
resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.ass-subnet.id
  route_table_id = aws_route_table.ass-rt.id
}



# Security Groups Setup
resource "aws_security_group" "ass-sg" {
  name        = "ass-sg"
  description = "enable traffic on port 22, 80 ,443"
  vpc_id      = aws_vpc.ass-vpc.id

  ingress {
    description      = "HTTPS Traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTP Traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "HTTPS Traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ass-sg1"
  }
}



# Network interface setup
resource "aws_network_interface" "ass-ni" {
  subnet_id       = aws_subnet.ass-subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.ass-sg.id]
}


# Create an elastic ip associate with network interface
resource "aws_eip" "ass-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.ass-ni.id
  associate_with_private_ip = "10.0.1.10"
}



# Ec2 Instance setup and attaching the network interface to it
resource "aws_instance" "ass-instance" {
  ami           = "ami-02eb7a4783e7e9317" # ap-south-1
  instance_type = "t2.medium"
  availability_zone = "ap-south-1a"
  key_name = "DevOps-key"

  network_interface {
    network_interface_id = aws_network_interface.ass-ni.id
    device_index         = 0
  }

  user_data = <<EOF
              #!/bin/bash
              sudo su 
              sudo apt update
              sudo apt install docker.io -y
              curl -sfL https://get.k3s.io | sh -
              EOF

 tags = {
       Name = "Kubernetes Cluster"
 }
}




