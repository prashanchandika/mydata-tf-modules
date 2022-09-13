/* output "sftp_public_ip" {
    value = aws_instance.sftp.public_ip
}

output "sftp_public_dns" {
    value = aws_instance.sftp.public_dns
} */


output "eip" {
    value = aws_eip.eip.public_ip
}