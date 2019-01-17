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

data "template_file" "config-ecs" {
  template = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster.id} > /etc/ecs/ecs.config
  EOF
}

data "aws_iam_policy_document" "task-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

###################
# AWS Key pair
###################
resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = "${var.ssh_public_key}"
}

###################
# Autoscaling group
###################
resource "aws_launch_configuration" "app_conf" {
  name   = "app_config"
  image_id      = "ami-c91624b0"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ec2-key.key_name}"
  security_groups = ["${aws_security_group.ec2-sg.name}"]
  user_data = "${base64encode(data.template_file.config-ecs.rendered)}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.arn}"
}

resource "aws_autoscaling_group" "app_autoscaling" {
  availability_zones = ["eu-west-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  launch_configuration = "${aws_launch_configuration.app_conf.name}"
  tags = [{
    key = "Name"
    value = "HelloWorld"
    propagate_at_launch = true
  }]
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

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################
# IAM Roles
###################
resource "aws_iam_role" "task_role" {
  name = "task_role"
  path =  "/"
  assume_role_policy = "${data.aws_iam_policy_document.task-role-policy.json}"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  path =  "/"
  assume_role_policy = "${data.aws_iam_policy_document.ec2-role-policy.json}"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "test_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role_policy_attachment" "attach-ecs-policy-to-task-role" {
  role       = "${aws_iam_role.task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "attach-ecs-policy-to-ec2-role" {
  role       = "${aws_iam_role.ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
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
  task_role_arn = "${aws_iam_role.task_role.arn}"
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

output "ecs_repository" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}
