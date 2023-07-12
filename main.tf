module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"

  identifier = var.identifier

  # Available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.DBVersions
  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family               # DB parameter group
  major_engine_version = var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                = var.db_name
  username               = var.username
  create_random_password = var.create_random_password
  password               = var.password # If 'create_random_password' is false, then 'password' must be set
  port                   = var.port

  multi_az               = var.multi_az
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_role_permissions_boundary  = var.monitoring_role_permissions_boundary
  monitoring_interval                   = 60
  monitoring_role_name                  = "${var.db_name}-rds-monitoring-role"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"

  create_db_parameter_group = var.create_db_parameter_group

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }

  tags = var.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name        = var.db_name
  description = "Complete PostgreSQL example security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = var.tags
}

################################################################################
# RDS Automated Backups Replication Module
################################################################################

data "aws_caller_identity" "current" {}

module "kms" {
  source  = "github.com/defenseunicorns/uds-iac-aws-kms?ref=v0.0.1-alpha"

  count = var.automated_backups_replication_enabled ? 1 : 0

  kms_key_description       = "KMS key for cross region automated backups replication"
  kms_key_alias_name_prefix = var.db_name
  key_owners                = [data.aws_caller_identity.current.arn]

  tags = var.tags
}

module "db_automated_backups_replication" {
  source  = "terraform-aws-modules/rds/aws//modules/db_instance_automated_backups_replication"
  version = "6.1.0"

  count = var.automated_backups_replication_enabled ? 1 : 0

  source_db_instance_arn = module.db.db_instance_arn
  kms_key_arn            = module.kms[0].kms_key_arn
}
