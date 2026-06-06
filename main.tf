# AWS Provider
provider "aws" {
  region = "us-east-2"
}

# -----------------------------------
# Security Group
# -----------------------------------

resource "aws_security_group" "terraform_sg" {
  name        = "terraform-security-group"
  description = "Allow SSH HTTP HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------
# EC2 Instance
# -----------------------------------

resource "aws_instance" "terraform_server" {

  ami           = "ami-0fe18bc3cfa53a248" # Ubuntu 22.04 us-east-2
  instance_type = "t3.micro"
  key_name      = "terraform"

  security_groups = [aws_security_group.terraform_sg.name]

  availability_zone = "us-east-2a"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx git -y

              cd /tmp
              git clone https://github.com/sunnybunny24109/profile-Rajesh.git

              sudo rm -rf /var/www/html/*
              sudo mv profile-Rajesh/* /var/www/html/

              sudo systemctl enable nginx
              sudo systemctl restart nginx
              EOF

  tags = {
    Name = "terraform_server"
  }
}

# -----------------------------------
# Output
# -----------------------------------

output "public_ip" {
  value = aws_instance.terraform_server.public_ip
}

output "public_dns" {
  value = aws_instance.terraform_server.public_dns
}
