terraform {
  backend "s3" {
    bucket         = "simple-budget-tf-state"
    key            = "sample-rails.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "simple-budget-tf-state-lock"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  version = "~> 2.54.0"
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {
  name = "ap-southeast-1"
} # so we don't need to hardcode the region in other files