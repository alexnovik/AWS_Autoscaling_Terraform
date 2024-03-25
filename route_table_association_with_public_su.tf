# Route_table_association_with_public_subnets.tf

resource "aws_route_table_association" "devops-public1" {
    subnet_id = "${aws_subnet.devops-public1.id}"
    route_table_id = "${aws_route_table.devops-public.id}"
}

