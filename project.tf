#iam credentials
provider "aws" {
  region = "us-east-1"
  access_key = "AKIAWASELB6UL2GGBMFI"
  secret_key = "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" #security vulnerabilitiess
}

resource "aws_instance" "instance"{
  ami = "ami-0aeeebd8d2ab47354"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  count         = var.instance_count
  tags = {
      Name  = "Terraform-${count.index + 1}"
  }
  
}
variable "instance_count" {
  default = "20"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "all" {}


resource "aws_launch_configuration" "webserver" {
  image_id        = "ami-0aeeebd8d2ab47354"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Terraform whuwhuu" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "instance" {
  launch_configuration = aws_launch_configuration.webserver.id
  availability_zones   = data.aws_availability_zones.all.names
   
   
  min_size = 6
  max_size = 8
  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}