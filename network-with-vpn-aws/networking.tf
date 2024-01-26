

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name       = var.project_name
    managed-by = "terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name       = var.project_name
    managed-by = "terraform"
  }
}

resource "aws_eip" "nat_gateway" {
  tags = {
    Name       = "nat-gateway"
    managed-by = "terraform"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_1.id
  tags = {
    Name       = var.project_name
    managed-by = "terraform"
  }
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name       = "ece-public"
    managed-by = "terraform"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name       = "ece-private"
    managed-by = "terraform"
  }

}

resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.aws_availability_zone_1
  cidr_block              = local.public_network_cidr_1
  map_public_ip_on_launch = true
  tags = {
    Name       = "ece-servers-public-1"
    managed-by = "terraform"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.aws_availability_zone_2
  cidr_block              = local.public_network_cidr_2
  map_public_ip_on_launch = true
  tags = {
    Name       = "ece-servers-public-2"
    managed-by = "terraform"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.aws_availability_zone_1
  cidr_block              = local.private_network_cidr_1
  map_public_ip_on_launch = false
  tags = {
    Name       = "ece-servers-private-1"
    managed-by = "terraform"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.aws_availability_zone_2
  cidr_block              = local.private_network_cidr_2
  map_public_ip_on_launch = false
  tags = {
    Name       = "ece-servers-private-2"
    managed-by = "terraform"

  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private_private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
