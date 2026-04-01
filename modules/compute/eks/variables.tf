variable "subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
  type        = string
  description = "EKS Cluster Role ARN"
}

variable "node_role_arn" {
  type        = string
  description = "EKS Node Role ARN"
}
