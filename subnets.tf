# Create subnets

resource "aws_subnet" "devops-public1" {
   vpc_id            = aws_vpc.vpc.id
   cidr_block        = "10.0.1.0/24"
   map_public_ip_on_launch = true
   depends_on = [aws_vpc.vpc]
   availability_zone = "us-east-2a"
   tags = {
     Name = "devops-public-1"
   }
 }

 resource "aws_subnet" "devops-private1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "false"
    depends_on = [aws_vpc.vpc]
    availability_zone = "us-east-2a"
    tags = {
       Name = "devops-private1"
   }
}
