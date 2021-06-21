#iam credentials
provider "aws" {
  region = "us-east-1"
  access_key = "AKIAWASELB6UOXBTPALX"
  secret_key = "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"
}
resource "aws_instance" "first-instance" {
  ami           = "ami-0d8d212151031f51c "
  instance_type = "t2.micro"
}