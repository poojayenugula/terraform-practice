module "network" {
  source              = "../day-6-customnetworkcreation"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  ami_id              = "ami-0d03cb826412c6b0f"
  instance_type       = "t2.micro"
  key_name            = "Pubpvtkeypair"  # ✅ You have added your key name here — perfect!
}
