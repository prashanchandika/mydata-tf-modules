output "alb" {
    value = {
        arn =   aws_lb.alb1.arn
        id  =   aws_lb.alb1.id
        dns =   aws_lb.alb1.dns_name
    }
}


 