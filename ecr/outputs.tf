output "ecr_url" {
    description = "aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName"
    value = aws_ecr_repository.ecr1.repository_url
}