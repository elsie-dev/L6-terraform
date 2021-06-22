#iam credentials
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key =""
}

resource "aws_instance" "instance"{
  ami = "ami-0aeeebd8d2ab47354"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  count         = 20 # var.instance_count
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
#CREATING AN ELASTIC LOADBALANCER
# resource "aws_elb" "server" {
#   name               = "terraform-elb"
#   availability_zones = data.aws_availability_zones.all.names

#   access_logs {
#     bucket        = "foo"
#     bucket_prefix = "bar"
#     interval      = 60
#   }
#   listener {
#     lb_port                          = 80
#     lb_protocol                      = "http"
#     instance_port                    = var.server_port
#     instance_instance_protocol       = "http"
#   }
#   health_check {
    
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTP:${var.server_port}/"
#     interval            = 30
#   }

#   cross_zone_load_balancing   = true
#   idle_timeout                = 400
#   connection_draining         = true
#   connection_draining_timeout = 400

#   tags = {
#     Name = "Load-balancer Terraform"
#   }
# }


resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  security_groups    = [aws_security_group.instance.id]
  availability_zones = data.aws_availability_zones.all.names

   health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}
#adding ssl certificate course of constant errors
# resource "aws_acm_certificate" "default" {
#   provider = "aws.acm"
#   domain_name = "${var.domain}"
#   subject_alternative_names = ["*.${var.domain}"]
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
# }
