provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev-vpc"
  }
}

# Subnet 1 - ap-south-1a
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "subnet-1"
  }
}

# Subnet 2 - ap-south-1b
resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "subnet-2"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "sub_grp" {
  name       = "mycustsubnet"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "my db subnet group"
  }
}

# IAM Role for RDS Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS MySQL Instance
resource "aws_db_instance" "default" {
  allocated_storage       = 10
  identifier              = "book-rds"
  db_name                 = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "Pooja_RDS"
  password                = "poojards0011"
  db_subnet_group_name    = aws_db_subnet_group.sub_grp.name
  parameter_group_name    = "default.mysql8.0"

  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled = false  # Disabled for t2.micro

  maintenance_window      = "sun:04:00-sun:05:00"
  deletion_protection     = true
  skip_final_snapshot     = true

  publicly_accessible     = false

  depends_on = [aws_db_subnet_group.sub_grp]
}




# Secret metadata (container)
resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "book-rds-secret"
  description = "RDS credentials for book-rds instance"
}

# Secret version with the actual values
resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = aws_db_instance.default.address
    username = "Pooja_RDS"
    password = "poojards0011"
    dbname   = "mydb"
    port     = 3306
  })
}

