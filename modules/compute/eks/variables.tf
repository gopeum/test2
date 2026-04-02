variable "project_name" { type = string }

variable "eks_cluster_version" { type = string }

variable "cluster_security_group_id" { type = string }

variable "eks_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "node_instance_type" { default = "t3.micro" }

variable "web_min" { default = 1 }
variable "web_desired" { default = 1 }
variable "web_max" { default = 2 }

variable "was_min" { default = 1 }
variable "was_desired" { default = 1 }
variable "was_max" { default = 2 }
