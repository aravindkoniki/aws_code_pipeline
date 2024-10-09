output "id" {
  value       = [for build in aws_codebuild_project.codebuild_project : build.id]
  description = "List of IDs of the CodeBuild projects"
}

output "arn" {
  value       = [for build in aws_codebuild_project.codebuild_project : build.arn]
  description = "List of ARNs of the CodeBuild projects"
}

