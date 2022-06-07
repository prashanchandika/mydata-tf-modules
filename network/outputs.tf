output "vpc" {
  value = {
    id                  = "${module.vpc.vpc.id}"
    cidr                = "${module.vpc.vpc.cidr}"
    private_subnet_ids  = "${module.vpc.vpc.private_subnet_ids}"
    public_subnet_ids  = "${module.vpc.vpc.public_subnet_ids}"
    #nat_gateway_ids    = var.vpc.nat_gateway_ids
    #nat_gateway_public_ips = var.vpc.nat_gateway_public_ips
    #main_route_table_id     = var.main_route_table_id
    #public_route_table_id   = var.public_route_table
    #private_route_table_ids = var.private_route_tables
  }
}