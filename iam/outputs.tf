output "lambda_iam_role" {
    value = aws_iam_role.iam_for_lambda.arn
}


output "rds_proxy_iam_role" {
    value = aws_iam_role.rds_proxy_role.arn
}


output "ecs_exec_iam_role" {
    value = aws_iam_role.iam_for_ecs.arn
}
