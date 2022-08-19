variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "CIDR block for Private Subnet"
}

variable "region" {
  description = "Region in which the bastion host will be launched"
}

variable "availability_zones" {
  type        = list
  description = "AZ in which all the resources will be deployed"
}