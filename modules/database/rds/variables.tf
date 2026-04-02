variable "project" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_user" {
  type    = string
  default = "admin"
}

variable "db_pass" {
  type      = string
  sensitive = true
}

variable "rds_sg_id" {
  type = string
}