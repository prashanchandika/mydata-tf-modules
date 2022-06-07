output "s3" {
    value = {
        name = aws_s3_bucket.s3bucket1.id
        arn = aws_s3_bucket.s3bucket1.arn
    }
}