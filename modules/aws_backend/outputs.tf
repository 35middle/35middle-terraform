# output "alb_hostname" {
#   value       = aws_lb.main.dns_name
#   description = "value"
# }


# output "cluster" {
#   value = aws_ecs_service.main
# }

output "ecr_url" {
  value = aws_ecr_repository.main.repository_url
}

