provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# Add RDS PostgreSQL Aurora
resource "aws_rds_cluster" "medusa_db" {
  cluster_identifier = "medusa-db"
  engine             = "aurora-postgresql"
  master_username    = "admin"
  master_password    = "yourpassword"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
}

output "db_endpoint" {
  value = aws_rds_cluster.medusa_db.endpoint
}
