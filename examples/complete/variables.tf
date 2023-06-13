variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR blocks"
  type        = list(string)
  default     = ["100.64.0.0/16"] // https://aws.amazon.com/blogs/containers/optimize-ip|109-addresses-usage-by-pods-in-your-amazon-eks-cluster/
}

variable "db_name" {
  description = "Name of the RDS DB"
  type        = string
  default     = "exdb"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "example-vpc"
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 5432
}
