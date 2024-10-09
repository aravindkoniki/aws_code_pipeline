variable "region" {
  description = "region to deploy"
  type        = string
}

variable "project_name" {
  description = "(Required) Unique name for this project"
  type        = string
}

variable "build_projects" {
  description = "(Required) List of Names of the CodeBuild projects to be created"
}

variable "stages" {
  description = "(Required)  List of Map containing information about the stages of the CodePipeline"
}

variable "full_repository_id" {
  description = "(Required) full repository id"
  type        = string
}

variable "code_pipeline_build_role_name" {
  description = "(Required) Friendly name of the role"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
