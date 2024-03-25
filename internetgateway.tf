# Create Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "capstone3_InternetGateway"
  }
}
#resource "aws_nat_gateway" "nat_gateway" {
#  allocation_id = aws_eip.elastic_ip.id
#  subnet_id     = aws_subnet.devops-public1.id
#  depends_on    = [aws_nat_gateway.nat_gateway]
#  tags = {
#    Name = "Capstone3_InternetGateway"
#  }
#}

#resource "aws_internet_gateway" "gw" {
#    vpc_id = "${aws_vpc.main.id}"
#
#    tags = {
#        Name = "MainGW"
#    }
#}