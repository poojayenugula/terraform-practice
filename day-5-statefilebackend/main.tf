provider "aws" {
  
}
resource "aws_instance" "name" {
  ami = "ami-0d03cb826412c6b0f"
  instance_type = "t2.micro"
  key_name = ""
  tags = {

Name = "day-5"
  }
  
}