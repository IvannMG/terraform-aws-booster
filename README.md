# 🚀 terraform-aws-booster 🚀

This plugin is made to help developer to create a free ubuntu instance in AWS.

This is a really good tool for creating a POC or a personal project.

## Prerequisites

- [Terraform](https://www.vasos-koupparis.com/terraform-getting-started-install/)(2 minutes)

## Usage

- create a ssh key to get access to your ec2 instances

`
ssh-keygen -t rsa -C "example@example.fr"
`

- create a `main.tf` file and make the mandatory changes

```

provider "aws" {
  region = "eu-west-1" // 1. Change this to use your favorite region
  profile = "myprofile" // 2. Change this to use your aws profile name
}

module "ec2" {
  source = "git::https://github.com/IvannMG/terraform-aws-booster.git?ref=master" 

  project_name = "my-project-name" // 3. Change this to use your aws profile name
  ssh_public_key = "ssh-rsa ...." // 4. Change this to use your profile name
}

output "Public IP" {
  description = "EC2 public IP"
  value       = "${module.ec2.public_ip}"
}

output "Public DNS" {
  description = "EC2 public DNS"
  value       = "${module.ec2.public_dns}"
```

Then launch terraform

`
terraform init
terraform plan
terraform apply
`

Happy Coding 💪
