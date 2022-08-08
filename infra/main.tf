provider "aws" {
  region  = var.aws_region
}

locals {
  # Target port to expose
  target_port = 3000
}

module "networking" {
  source = "github.com/Jareechang/tf-modules//networking?ref=v1.0.1"
  env = var.env
  project_id = var.project_id
  subnet_public_cidrblock = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  subnet_private_cidrblock = [
    "10.0.11.0/24",
    "10.0.22.0/24"
  ]
  azs = ["ap-southeast-2a", "ap-southeast-2b"]
}

#### Security groups
resource "aws_security_group" "alb_ecs_sg" {
  vpc_id = module.networking.vpc_id

  ## Allow inbound on port 80 from internet (all traffic)
  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ## Allow outbound to ecs instances in private subnet
  egress {
    protocol    = "tcp"
    from_port   = local.target_port
    to_port     = local.target_port
    cidr_blocks = module.networking.private_subnets[*].cidr_block
  }
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = module.networking.vpc_id
  ingress {
    protocol         = "tcp"
    from_port        = local.target_port
    to_port          = local.target_port
    security_groups  = [aws_security_group.alb_ecs_sg.id]
  }

  ## Allow ECS service to reach out to internet (download packages, pull images etc)
  egress {
    protocol         = -1
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

module "ecs_tg" {
  source              = "github.com/Jareechang/tf-modules//alb?ref=v1.0.2"
  create_target_group = true
  port                = local.target_port
  protocol            = "HTTP"
  ## This is important! *
  target_type         = "ip"
  vpc_id              = module.networking.vpc_id
}

module "alb" {
  source             = "github.com/Jareechang/tf-modules//alb?ref=v1.0.2"
  create_alb         = true
  enable_https       = false
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_ecs_sg.id]
  subnets            = module.networking.public_subnets[*].id
  target_group       = module.ecs_tg.tg.arn
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "main" {
  name                 = "web/${var.project_id}/nextjs"
  image_tag_mutability = "MUTABLE"
}

## CI/CD user role for managing pipeline for AWS ECR resources
module "ecr_ecs_ci_user" {
  source            = "github.com/Jareechang/tf-modules//iam/ecr?ref=v1.0.12"
  env               = var.env
  project_id        = var.project_id
  create_ci_user    = true
  # This is the ECR ARN - Feel free to add other repository as required (if you want to re-use role for CI/CD in other projects)
  ecr_resource_arns = [
    "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/web/${var.project_id}",
    "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/web/${var.project_id}/*"
  ]
  other_iam_statements = {}
}