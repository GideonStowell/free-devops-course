terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
  profile = "terraform"
}

data "aws_ami" "webserver_os" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.webserver_os.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.firewall.id]
  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "ExampleWebServer"
  }
}

resource "aws_security_group" "firewall" {
  name = "webserver-security-group"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
