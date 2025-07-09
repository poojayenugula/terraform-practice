provider "aws" {
  
}
resource "aws_instance" "name" {
  ami = "ami-0d03cb826412c6b0ff"
  instance_type = "t2.micro"
  key_name = "mykeypair"
  tags = {

Name = "day-4"
  }
  
}
resource "aws_s3_bucket" "name" {
    bucket = "honeyyyyyyys3terraform"
  
}