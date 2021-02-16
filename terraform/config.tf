provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tfstate-vsdev1.de"
    region = "eu-central-1"
    key = "appsyncmasterclass-frontend/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
  }
}