resource "aws_codebuild_project" "codebuild_project" {
  for_each       = var.build_projects
  name           = "${var.project_name}-${each.value["name"]}"
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn

  artifacts {
    type     = lookup(each.value, "artifacts_type", "CODEPIPELINE")
    location = lookup(each.value, "artifacts_location", null)
  }
  environment {
    compute_type                = lookup(each.value, "builder_compute_type", "BUILD_GENERAL1_SMALL")
    image                       = lookup(each.value, "builder_image", "aws/codebuild/standard:7.0")
    type                        = lookup(each.value, "builder_type", "LINUX_CONTAINER")
    privileged_mode             = lookup(each.value, "builder_privileged_mode", true)
    image_pull_credentials_type = lookup(each.value, "builder_image_pull_credentials_type", "CODEBUILD")
  }
  logs_config {
    cloudwatch_logs {
      status      = lookup(each.value, "cloudwatch_logs_enabled", "ENABLED")
      group_name  = lookup(each.value, "cloudwatch_logs_group_name", null)
      stream_name = lookup(each.value, "cloudwatch_logs_stream_name", null)
    }
  }
  source {
    type      = lookup(each.value, "build_project_source", "CODEPIPELINE")
    buildspec = "buildspecs/${each.value["buildspec"]}.yml"
  }

  tags = merge({ "Name" = upper("${each.value["name"]}"), "ManagedBy" = "Terraform", "Creation Date" = timestamp() }, lookup(each.value, "tags", {}))
  lifecycle {
    ignore_changes = [tags["Creation Date"]]
  }
}
