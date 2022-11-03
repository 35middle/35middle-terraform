variable "prefix" {
  description = "Prefix for all the ecs resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
}

variable "availability_zones" {
  description = "the region configured in the provider"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}

variable "app_count" {
  description = "Number of docker containers to run"
}

variable "health_check_path" {
}

variable "ecr_image_name" {
  description = "Unique name of the ECR image name"
  type        = string
}

variable "release_version" {
  type        = string
  description = "Image version which needs to be deployed"
  default     = "latest"
}

variable "aws_acm_certificate_domain" {
  description = "issured acm domian"
}