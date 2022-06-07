output "secrets_manager" {
    value = {
        id      = aws_secretsmanager_secret.rds_secret.id
        name    = aws_secretsmanager_secret.rds_secret.name
        arn     = aws_secretsmanager_secret.rds_secret.arn
    }
}