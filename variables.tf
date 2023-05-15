variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
  default     = ""
}

variable "database_subnet_group_name" {
  description = "The name of the database subnet group."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = ""
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
  default     = ""
}

variable "engine" {
  description = "The database engine to use."
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
  default     = ""
}

variable "family" {
  description = "The family of the DB parameter group."
  type        = string
  default     = ""
}

variable "major_engine_version" {
  description = "The major version of the engine that this option group should be associated with."
  type        = string
  default     = ""
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = ""
}

variable "port" {
  description = "DB port"
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}

variable "allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
  default     = 0
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "identifier" {
  description = "The name of the DB instance, if omitted, Terraform will assign a random, unique identifier."
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled."
  type        = bool
  default     = false
}

variable "create_random_password" {
  description = "Whether to create random password for RDS primary cluster"
  type        = bool
  default     = true
}

variable "password" {
  description = <<EOF
  Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file.
  The password provided will not be used if the variable create_random_password is set to true.
  EOF
  type        = string
  default     = null
  sensitive   = true
}

variable "monitoring_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the monitoring IAM role"
  type        = string
  default     = null
}

variable "automated_backups_replication_enabled" {
  description = "Whether to create automated backups replication."
  type        = bool
  default     = false
}

variable "create_db_parameter_group" {
  description = "Whether to create a database parameter group."
  type        = bool
  default     = false
}
