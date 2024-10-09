variable "project_name" {
  description = "(Required) Unique name for this project"
  type        = string
}

variable "source_code_provider" {
  description = "(Required) The provider of the service being called by the action. Valid providers are determined by the action category."
  default     = "CodeStarSourceConnection"
  type        = string
}

variable "connection_arn" {
  description = "(Required) Code starconnection arn"
  type        = string
}

variable "full_repository_id" {
  description = "(Required) full repository id"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
  default     = "main"
}

variable "s3_bucket_name" {
  description = "(Required) S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "(Required) ARN of the codepipeline IAM role"
  type        = string
}

variable "kms_key_arn" {
  description = "(Required) ARN of KMS key for encryption"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "stages" {
  description = "(Required)  List of Map containing information about the stages of the CodePipeline"
}
