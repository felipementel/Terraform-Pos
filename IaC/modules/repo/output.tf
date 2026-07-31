output "repository_name" {
  description = "The name of the created GitHub repository"
  value       = github_repository.repo.name
}
