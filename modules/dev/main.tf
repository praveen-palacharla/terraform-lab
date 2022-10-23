terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name
    bucket = "mystate-file-s3-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"

    #Replace this with your Dynamodb table name
    dynamodb_table = "mystatefile-dynamo-locks"
    encrypt        = true
  }
}

resource "aws_vpc" "t_my_vpc_01" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc-1"
  }
}

resource "aws_subnet" "t_public_subnet" {
  vpc_id     = aws_vpc.t_my_vpc_01.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-public-subnet"
  }
}

resource "aws_internet_gateway" "t_igw" {
  vpc_id = aws_vpc.t_my_vpc_01.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "t_public_rt" {
  vpc_id = aws_vpc.t_my_vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.t_igw.id
  }

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route_table_association" "t_public_rt_assoc" {
  subnet_id      = aws_subnet.t_public_subnet.id
  route_table_id = aws_route_table.t_public_rt.id
}

resource "aws_security_group" "t_sgrp" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
 vpc_id = aws_vpc.t_my_vpc_01.id

  tags = {
    Name = "dev-terraform_created_sg"
  }
}


resource "aws_instance" "t_praveen_server" {
  ami           = "ami-09d3b3274b6c5d4aa"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.t_public_subnet.id

  tags = {
    Name = "dev-web-server-1"
  }
}

