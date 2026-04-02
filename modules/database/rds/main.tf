resource "aws_db_instance" "this" {
  identifier = "${var.project}-rds"

  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  db_name  = "appdb"
  username = var.db_user
  password = var.db_pass

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "${var.project}-rds"
  }
}