variable "db_pass" {
  type      = string
  sensitive = true
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "bucket_name" {
  type = string
}
