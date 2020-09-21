variable "ovner" {
  description = "Ovner"
  default     = "Dmitry_Chernov"
}

variable "project" {
  description = "Project name"
  default     = "by-terraform"
}

variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "key" {
  default = "TEST_AWS"
}
