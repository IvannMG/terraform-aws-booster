// 1. Define your provider
provider "aws" {
  region = "eu-west-1"
  profile = "kevin"
}

// 2. Configure your module
module "ec2" {
  source = "../"

  // project parameters
  project_name = "overlay"
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFBHKk9jp1WFF9BYKeCZBeG1Hpig0ZbA731Dd43qsHAyKRj/EtBsQ3te7j/i+uXf6kHu8xSHjKToJuL2IWzQ5S2o+XI5nSC+8UP11goAdnlh50MiqyOyizNeFaEOF/NPig2r78JmKJVa7DLmRKiNgXHuqwe5pbFMUQV56z8BuQTFJW/BMK4yrBBpV2xk10vzcKDK9l0EFI2iHkVlIgRDh+czuoAurd/S9xRIMqNNXtv8R7ZB7Pag+i2Yyptp1UJdAjSEGNzCetC+AWXAScKcBC0O36jjLHHxZfx9fD8J9ZeW9VzXWvGZWIm7vy1HnRoiqK9RUG83eDCAhxYwTWO8yd kevinj@theodo.fr"
}

// 3. Define your outputs
output "Public Ip" {
  description = "EC2 public IP"
  value       = "${module.ec2.public_ip}"
}

output "Public DNS" {
  description = "EC2 public DNS"
  value       = "${module.ec2.public_dns}"
}
