provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
  profile = "your-local-aws-profile"
}

resource "aws_security_group" "nginx" {
  name = "allow_internet_traffic"
  description = "Allow http internet traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "http from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_internet_traffic"
  }
}

resource "aws_security_group" "nginx_ssh" {
  name = "allow_ssh"
  description = "Allow ssh traffic"
  vpc_id = var.vpc_id

  ingress {
    description = "allow ssh connections"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your-ip-address/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "nginx" {
  key_name = "nginx"
  public_key = file("./id_rsa.pub")
}

resource "aws_instance" "nginx" {
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.nginx.key_name

  subnet_id = var.public_subnet_id
  security_groups = [aws_security_group.nginx.id, aws_security_group.nginx_ssh.id]

  user_data = file("./user_data.sh")

  tags = {
    Name = "nginx"
  }
}