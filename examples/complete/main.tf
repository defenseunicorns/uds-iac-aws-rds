data "aws_availability_zones" "available" {}

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
  default     = ["100.64.0.0/16"] #https://aws.amazon.com/blogs/containers/optimize-ip|109-addresses-usage-by-pods-in-your-amazon-eks-cluster/
}

module "rds" {
  source = "../.."

  vpc_cidr = module.vpc.vpc_cidr_block
  vpc_id   = module.vpc.vpc_id

  database_subnet_group_name = module.vpc.database_subnet_group_name
  db_name                    = "exdb"
  username                   = "exampleadmin"
  engine                     = "postgres"
  engine_version             = "14"
  family                     = "postgres14" # DB parameter group
  major_engine_version       = "14"         # DB option group
  instance_class             = "db.m7g.large"
  allocated_storage          = "10"
  max_allocated_storage      = 20
  identifier                 = "exampleclusterdb"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name                  = "example-vpc"
  cidr                  = var.vpc_cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]
  database_subnet_group_name = "example-db-subnet-group"

  single_nat_gateway    = true
  enable_nat_gateway    = true

  create_database_subnet_group = true
}
