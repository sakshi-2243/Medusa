resource "aws_ecr_repository" "medusa" {
  name = "medusa-backend"
}

output "repository_url" {
  value = aws_ecr_repository.medusa.repository_url
}
