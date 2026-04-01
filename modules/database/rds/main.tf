resource "aws_db_subnet_group" "this" {
  name       = "test2-db-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  allocated_storage = 20
  engine            = "mysql"
  instance_class    = "db.t3.micro"

  username = var.db_user
  password = var.db_pass

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot  = true
}

resource "aws_security_group" "rds_sg" {
  name   = "test2-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}