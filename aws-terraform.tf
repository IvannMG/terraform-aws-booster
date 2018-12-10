variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "example" {
  ami           = "ami-047bb4163c506cd98"
  instance_type = "t2.micro"
  tags {
    Name = "HelloWorld"
  }

  security_groups = ["example-sg"]
}

resource "aws_security_group" "example-sg" {
  name        = "example-sg"
  description = "Test security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}