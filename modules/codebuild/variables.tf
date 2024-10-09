variable "project_name" {
  description = "(Required) Unique name for this project"
  type        = string
}

variable "role_arn" {
  description = "(Required) Codepipeline IAM role arn. "
  type        = string
}

variable "s3_bucket_name" {
  description = "(Optional) Name of the S3 bucket used to store the deployment artifacts"
  type        = string
  default     = null
}

variable "tags" {
  description = "(Required) A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "build_projects" {
  description = "(Required) List of Names of the CodeBuild projects to be created"
}

variable "kms_key_arn" {
  description = "(Optional) ARN of KMS key for encryption"
  type        = string
  default     = null
}
