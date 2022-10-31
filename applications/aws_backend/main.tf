terraform {
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}


module "aws_backend" {
  source             = "../../modules/aws_backend"
  prefix             = "35middle"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  ecr_image_name     = "35middle-backend-image"
  az_count="3"
  environment = "uat"
  app_port = "3001"
  ecs_task_execution_role_name = "myEcsTaskExecutionRole"
  fargate_cpu = "512"
  fargate_memory = "1024"
  app_count = "1"
  health_check_path = "/"
}