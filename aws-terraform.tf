variable "access_key" {}
variable "secret_key" {}
variable "ssh_public_key" {}
variable "region" {
  default = "eu-west-1"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = "${var.ssh_public_key}"
}

data "template_file" "config-ecs" {
  template = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.id} > /etc/ecs/ecs.config
  EOF
}

###################
# EC2 instance
###################
resource "aws_instance" "ec2" {
  ami = "ami-c91624b0"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ec2-key.key_name}"
  tags {
    Name = "HelloWorld"
  }

  security_groups = ["ec2-sg"]
  user_data = "${base64encode(data.template_file.config-ecs.rendered)}"
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

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_ecs_task_definition" "deployment-task" {
  family = "deployment-task"
  network_mode = "bridge"
  container_definitions = <<DEFINITION
  [
    {
      "name": "deploy",
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

###################
# ECS Service
###################
resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = "${aws_ecs_cluster.ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.deployment-task.arn}"
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
}
