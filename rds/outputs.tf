output "db_host" {
    value = aws_db_instance.rds1.*.address
}

output "db_user" {
    value = var.username
}

output "db_seret_name" {
    value = module.rds_secret.secrets_manager["name"]
}

output "db_seret_arn" {
    value = module.rds_secret.secrets_manager["id"]
}

output "rds_proxy_endpoint" {
    value = aws_db_proxy.db_proxy1.endpoint
}

output "rds_proxy_arn" {
    value = aws_db_proxy.db_proxy1.arn
}