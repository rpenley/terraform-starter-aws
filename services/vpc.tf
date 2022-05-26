// This starter template only creates a single VPC labeled primary as the typical configuration a large organization will want its to seperate environments by account
// If you wish instead to create a VPC for each environment i.e. a VPC for dev,test,staging,production then you will need to duplicate all work in this repo for each environment
// For example you will want to restructure the root to use each environment instead or duplicate this repo for each environment and apply them to the same account

// Primary VPC
resource "aws_vpc" "primary" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "primary",
    Description = "Primary VPC managed by terraform"
  }
}

// Primary Internet Gateway
resource "aws_internet_gateway" "primary_igw" {
  vpc_id = aws_vpc.primary.id
}

// Primary Public Subnets
resource "aws_subnet" "primary_public" {
  vpc_id     = aws_vpc.primary.id
  cidr_block = var.public_subnets
}

// Primary Private Subnets
resource "aws_subnet" "primary_private" {
  vpc_id     = aws_vpc.primary.id
  cidr_block = var.private_subnets
}

// Primary Public Route Table
resource "aws_route_table" "primary_public" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

// Primary Private Route Table
resource "aws_route_table" "primary_private" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}

// Primary Public Subnets Route Table Association
resource "aws_route_table_association" "primary_public" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id
}

// Primary Private Subnets Route table Association
resource "aws_route_table_association" "primary_private" {
  subnet_id      = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id
}

// NAT Gateway Elastic IP
resource "aws_eip" "nat_gateway" {
  vpc = true
}

// NAT Gateway
resource "aws_nat_gateway" "primary" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnets.id
}
