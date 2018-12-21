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

###################
# EC2 instance
###################
resource "aws_instance" "ec2" {
  ami           = "ami-047bb4163c506cd98"
  instance_type = "t2.micro"
  tags {
    Name = "HelloWorld"
  }

  security_groups = ["ec2-sg"]
}

###################
# Security group
###################
resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "Test security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################
# ECR Repository
###################
resource "aws_ecr_repository" "ecr" {
  name = "kevin"
}

###################
# ECS Cluster
###################
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "kevin-cluster"
}

###################
# ECS Task Definition
###################

# See this issue for injecting ecr repository in container definition
# https://github.com/terraform-providers/terraform-provider-aws/issues/632

resource "aws_ecs_task_definition" "kevin-tasks" {
  family = "kevin-tasks"
  network_mode = "bridge"
  container_definitions = <<DEFINITION
  [
    {
      "name": "kevin-deployement",
      "image": "${aws_ecr_repository.ecr.repository_url}:latest",
      "essential": true,
      "memoryReservation": 512,
      "cpu": 256,
      "portMappings": [{
        "containerPort": 80,
        "hostPort": 0
      }]
    }
  ]
  DEFINITION
}
