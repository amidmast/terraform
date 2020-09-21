provider "aws" {
  region = var.region
}

## Раскоментировать для хранения terraform.tfstate в s3 bucket
terraform {
  backend "s3" {
    bucket = "amidmast-nginx-terraform"
    key = "state/terraform.tfstate"
    region = "eu-central-1"
  }
}

output "LB_url" {
  value = aws_alb.web.dns_name
}

output "az_list" {
  value = join(",", data.aws_availability_zones.available.names)
}
