variable "prefix" {
  default = "api"
}

variable "project" {
  default = "simple-budget"
}

variable "contact" {
  default = "binlong09@@gmail.com"
}

variable "db_username" {
  description = "Username for the RDS postgres instance"
}

variable "db_password" {
  description = "Password for the RDS postgres instance"
}

variable "bastion_key_name" {
  default = "simple-budget-bastion"
}

variable "ecr_image_api" {
  description = "ECR image for API"
  default     = "191215300852.dkr.ecr.ap-southeast-1.amazonaws.com/simple-budget"
}

variable "rails_master_key" {
  description = "Rails master key"
}