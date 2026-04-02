resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-db-subnet"
  }
}