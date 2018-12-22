# terraform-aws-booster

## Installation

- Install [Terraform](https://www.vasos-koupparis.com/terraform-getting-started-install/) (2 minutes)
- clone the repo

`
git clone git@github.com:IvannMG/terraform-aws-booster.git && cd terraform-aws-booster
`
- create a ssh key to get access to your ec2 instances
```
ssh-keygen -t rsa -C "example@example.fr"
``

- store your aws credentials and yous ssh public key in a file named `terraform.tfvars`

```
access_key = "{your_aws_access_key}"
secret_key = "{your_aws_secret_key}"
ssh_public_key = "{your_ssh_public_key}"
```

- launch an EC2 instance with a basic security group

`
terraform init
terraform apply -var-file="terraform.tfvars"
`

