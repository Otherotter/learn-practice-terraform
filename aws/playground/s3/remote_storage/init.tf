# ---------------------------------------------------------
# Initalization. Comment out to set up remote backend
# ---------------------------------------------------------
terraform {
  #backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "Test"
    }
  }
}
