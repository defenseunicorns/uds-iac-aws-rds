terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.46.0"
      configuration_aliases = [aws.replication_region]
    }
  }
}
