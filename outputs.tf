locals {
  public_ip = "${aws_instance.ec2.public_ip}"
  public_dns = "${aws_instance.ec2.public_dns}"

}

output "public_ip" {
  description = "Instance public IP instances"
  value       = ["${local.public_ip}"]
}

output "public_dns" {
  description = "Instance public DNS instances"
  value       = ["${local.public_dns}"]
}
