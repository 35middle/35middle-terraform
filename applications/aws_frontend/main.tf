terraform {
  backend "s3" {
    bucket = "35middle-terraform-state-bucket"
    key    = "path/to/my/key"
    region = "ap-southeast-2"
    dynamodb_table = "35middle-terraform-state-lock-dynamodb"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}