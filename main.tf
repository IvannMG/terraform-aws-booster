###################
# AWS Key pair
###################
resource "aws_key_pair" "ec2-key" {
  key_name   = "${var.project_name}-ec2-key"
  public_key = "${var.ssh_public_key}"
}

###################
# EC2 - Instance
###################
resource "aws_instance" "ec2" {
  ami           = "ami-09f0b8b3e41191524"
  instance_type = "t2.micro"
  monitoring    = true
  security_groups = ["${aws_security_group.ec2-sg.name}"]
  key_name = "${aws_key_pair.ec2-key.key_name}"

  tags = {
    Name = "${var.project_name}"
  }
}

###################
# Security group
###################
resource "aws_security_group" "ec2-sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "${var.project_name} security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
