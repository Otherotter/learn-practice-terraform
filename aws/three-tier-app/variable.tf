variable "region" {
  description = "Region Used for Application"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone_one" {
  description = "Availability Zone Alpha in Region"
  type        = string
  default     = "us-east-1a"
}
variable "availability_zone_two" {
  description = "Availability Zone Beta in Region"
  type        = string
  default     = "us-east-1b"
}
