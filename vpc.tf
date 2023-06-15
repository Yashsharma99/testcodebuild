#Create VPC
resource "aws_vpc" "TestVPC" {
 cidr_block = var.vpc_cidr
 #ipv6_cidr_block      = "2406:da1a:618:4500::/56"	
 enable_dns_hostnames = true
 enable_dns_support   = true
 assign_generated_ipv6_cidr_block = true
 
 tags = {
   Name = "Project VPC"
 }
}


#Create Pubic Subnet
resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.TestVPC.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 #ipv6_cidr_block = element(var.public_subnet_cidrs, count.index)
 #ipv6_cidr_block = cidrsubnet(aws_vpc.TestVPC.ipv6_cidr_block, 8, count.index)
 map_public_ip_on_launch = true

 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}


#Create Private Subnet 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.TestVPC.id
 cidr_block =  element(var.private_subnet_cidrs, count.index)
 #ipv6_cidr_block = cidrsubnet(aws_vpc.TestVPC.ipv6_cidr_block, 8, count.index)
 #ipv6_cidr_block =  element(var.private_subnet_cidrs_ipv6, count.index)
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}



# Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.TestVPC.id

  tags = {
    "Name" = "my-igw"
  }

  depends_on = [aws_vpc.TestVPC]
}



# Route Table(s)
# Route the public subnet traffic through the IGW
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.TestVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.main.id
}


resource "aws_eip" "eip" {
  vpc = true
  #count = length(aws_subnet.public_subnets)
  tags = {
    Name = "NAT EIP"
  }
}


# NAT Gateway
resource "aws_nat_gateway" "ngw" {
  #count         = length(aws_subnet.public_subnets)
  #subnet_id     = aws_subnet.public_subnets[count.index].id
  #allocation_id = aws_eip.eip[count.index].id
   allocation_id = aws_eip.eip.id
   subnet_id     = aws_subnet.public_subnets[0].id
   depends_on = [
      aws_internet_gateway.IGW,
      aws_eip.eip    ]


  tags = {
    Name = "NAT Gateway"
  }
}

# Add route to route table
resource "aws_route_table" "ngw_route_rule" {
  vpc_id = aws_vpc.TestVPC.id
  depends_on = [
      aws_nat_gateway.ngw
    ]

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "Private-rt"
  }
}

 resource "aws_route_table_association" "private_subnet_asso" {
    count = length(aws_subnet.public_subnets)
    subnet_id  = element(aws_subnet.private_subnets.*.id, count.index)
    route_table_id = aws_route_table.ngw_route_rule.id
    depends_on = [
      aws_route_table.ngw_route_rule,
      aws_subnet.private_subnets
    ]
 }

