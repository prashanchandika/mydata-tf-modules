output "vpc" {
  value = {
    id                  = aws_vpc.this.*.id
    cidr                = "${var.vpc_cidr}"
    private_subnet_ids  = aws_subnet.private.*.id
    public_subnet_ids   = aws_subnet.public.*.id
    #nat_gateway_ids    = var.vpc.nat_gateway_ids
    #nat_gateway_public_ips = var.vpc.nat_gateway_public_ips
    #main_route_table_id     = var.main_route_table_id
    #public_route_table_id   = var.public_route_table
    #private_route_table_ids = var.private_route_tables
  }
}