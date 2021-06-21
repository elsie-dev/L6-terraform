#iam credentials
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""#security vulnerabilitiess
}

resource "aws_instance" "instance-1"{
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
