# terraform-aws-booster

## Installation

- Install [Terraform](https://www.vasos-koupparis.com/terraform-getting-started-install/) (2 minutes)
- clone the repo

`
git clone git@github.com:IvannMG/terraform-aws-booster.git && cd terraform-aws-booster
`

- edit `terraform.tfvars` with your aws credentials :

```
access_key = "{your_aws_access_key}"
secret_key = "{your_aws_secret_key}"
```

- launch an EC2 instance with a basic security group

`
terraform init
terraform apply -var-file="terraform.tfvars"
`

