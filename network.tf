#------------------Public Subnets--------------------

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnet_cidrs
  vpc_id                  = var.vpc_id
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags                    = merge(var.shared_tags, var.public_subnet_cluster_tag, { Name = "${lookup(var.shared_tags, "Env", "")}-public-subnet-${each.key}" })
}

resource "aws_route_table" "public_subnets" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = merge(var.shared_tags, var.public_subnet_cluster_tag, { Name = "${lookup(var.shared_tags, "Env", "")}-routes-public-subnets-eks" })
}

resource "aws_route_table_association" "public_subnets" {
  count          = length([for s in aws_subnet.public_subnets : s.id])
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element([for s in aws_subnet.public_subnets : s.id], count.index)
}

# #-------------------NAT Gateways with Elastic IPs----------------------

# resource "aws_eip" "nat" {
#   count = length([for cidr in var.private_subnet_cidrs: cidr])
#   vpc = true
#   tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-nat-gw-eip-${count.index + 1}"})
# }

# resource "aws_nat_gateway" "nat" {
#   count = length([for cidr in var.private_subnet_cidrs: cidr])
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id = element(var.public_subnets_ids_to_private, count.index)
#   tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-nat-gw-${count.index + 1}"})
# }


# #-------------------Private Subnets and Routing-------------------------

# resource "aws_subnet" "private_subnets" {
#   for_each = var.private_subnet_cidrs
#   vpc_id = var.vpc_id
#   cidr_block = each.key
#   availability_zone = each.value
#   tags = merge(var.shared_tags, var.private_subnet_cluster_tag, { Name = "${lookup(var.shared_tags, "Env", "")}-private-subnet-${each.key}"})
# }

# resource "aws_route_table" "private_subnets" {
#   count = length([for cidr in var.private_subnet_cidrs: cidr])
#   vpc_id = var.vpc_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.nat[count.index].id
#   }
#   tags = merge(var.shared_tags, var.private_subnet_cluster_tag, { Name = "${lookup(var.shared_tags, "Env", "")}-route-private-subnet-${element(keys(var.private_subnet_cidrs), count.index)}"})
# }

# resource "aws_route_table_association" "private_subnets" {
#   count = length([for cidr in var.private_subnet_cidrs: cidr])
#   route_table_id = aws_route_table.private_subnets[count.index].id
#   subnet_id = element([for network in aws_subnet.private_subnets: network.id], count.index)
# }

#-------------------Security Group---------------------

resource "aws_security_group" "allow-web-traffic" {
  name        = "allow_web_kubernetes"
  description = "Allow web traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}