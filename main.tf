provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraform-s3-tfstate"
  acl    = "private"
}

terraform {
  backend "s3" {
    bucket = aws_s3_bucket.my_bucket.bucket
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_instance" "postgres_instance" {
  identifier           = "postgres-db"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  db_name              = "techchallenge"
  username             = "docker"   # Master username
  password             = "dockerTech"   # Master password
  parameter_group_name = "default.postgres14"
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "Postgres-RDS"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_public_access_sg"
  description = "Allow inbound access to PostgreSQL"

  ingress {
    from_port   = 5432
    to_port     = 5432
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

output "db_endpoint" {
  value = aws_db_instance.postgres_instance.endpoint
}
