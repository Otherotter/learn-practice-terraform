variable "region" {
  description = "Region Used for Application"
  type        = string
  default     = "us-east-1"
}

variable "avail_zone" {
  description = "Availbility zones used in vpc"
  type = object({
    zone_1 = string
    zone_2 = string
  })
  default = {
    zone_1 = "us-east-1a"
    zone_2 = "us-east-1b"
  }
}

variable "cidr_blocks" {
  description = "cidr block used in the VPC. For example subnets"
  type = object({
    anywhere          = string
    public_subnet_a1  = string
    private_subnet_b1 = string
    private_subnet_b2 = string
  })
  default = {
    anywhere          = "0.0.0.0/0"
    vpc               = "10.0.0.0/16"
    public_subnet_a1  = "10.0.1.0/24"
    private_subnet_b1 = "10.0.2.0/24"
    private_subnet_b2 = "10.0.3.0/24"
  }
}


variable "iam_groups" {
  default = {
    0 = "admins"
    1 = "software"
    2 = "quality"
    3 = "system"
    4 = "security"    
  }
}

variable "iam_user" {
  default = {
    0 = {
      "name"  = "alpha"
      "group" = "admins"
    }
    1 = {
      "name"  = "dev-foo"
      "group" = "developers"
    }
    2 = {
      "name"  = "cal-test"
      "group" = "testers"
    }
  }
}
