provider "aws" {
region = "us-east-1"
}

resource "aws_vpc" "one" {
tags = {
Name = "my-vpc"
}
cidr_block = "11.0.0.0/16"
instance_tenancy = "default"
enable_dns_hostnames = "true"
}

resource "aws_subnet" "two" {
vpc_id = aws_vpc.one.id
tags = {
Name = "terraform-subnet-public-1"
}
availability_zone = "us-east-1a"
cidr_block = "11.0.1.0/24"
map_public_ip_on_launch = "true"
}

resource "aws_subnet" "three" {
vpc_id = aws_vpc.one.id
tags = {
Name = "terraform-subnet-private-1"
}
availability_zone = "us-east-1a"
cidr_block = "11.0.2.0/24"
}

resource "aws_subnet" "four" {
vpc_id = aws_vpc.one.id
tags = {
Name = "terraform-subnet-private-2"
}
availability_zone = "us-east-1b"
cidr_block = "11.0.3.0/24"
}

resource "aws_internet_gateway" "five" {
tags = {
    Name = "terraform-igw"
}
vpc_id = aws_vpc.one.id
}

resource "aws_route_table" "six" {
tags = {
    Name = "terraform-public-rt"
}
vpc_id = aws_vpc.one.id
route {
    gateway_id = aws_internet_gateway.five.id
    cidr_block = "0.0.0.0/0"
}
}

resource "aws_route_table" "seven" {
tags = {
    Name = "terraform-private-rt"
}
vpc_id = aws_vpc.one.id
route {
    gateway_id = aws_nat_gateway.nine.id
    cidr_block = "0.0.0.0/0"
}
}


resource "aws_eip" "eight" {
    #vpc = true
    tags = {
        Name = "aws-eip"
    }
}

resource "aws_nat_gateway" "nine" {
tags = {
    Name = "my-nat"
}
allocation_id = aws_eip.eight.id
subnet_id = aws_subnet.two.id
}



resource "aws_route_table_association" "public-1" {
  subnet_id = aws_subnet.two.id
  route_table_id = aws_route_table.six.id
}

resource "aws_route_table_association" "private-1" {
  subnet_id = aws_subnet.three.id
  route_table_id = aws_route_table.seven.id
}

resource "aws_route_table_association" "private-2" {
  subnet_id = aws_subnet.four.id
  route_table_id = aws_route_table.seven.id
}



