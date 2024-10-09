resource "aws_codepipeline" "code_pipeline" {

  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = var.source_code_provider
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        BranchName       = var.source_repo_branch
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.full_repository_id
        DetectChanges    = true
      }
    }
  }

  dynamic "stage" {
    for_each = local.stages_sorted

    content {
      name = stage.value["name"]
      action {
        category         = lookup("${stage.value}", "category", "Build")
        name             = stage.value["name"]
        owner            = lookup("${stage.value}", "owner", "AWS")
        provider         = lookup("${stage.value}", "provider", "CodeBuild")
        input_artifacts  = stage.value["input_artifacts"]
        output_artifacts = stage.value["output_artifacts"]
        version          = "1"
        run_order        = tonumber("${stage.value["run_order"]}") + 1

        configuration = {
          ProjectName = "${var.project_name}-${stage.value["name"]}"
        }
      }
    }
  }

  tags = merge({ "Name" = "${var.project_name}", "ManagedBy" = "Terraform", "Creation Date" = timestamp() })
  lifecycle {
    ignore_changes = [tags["Creation Date"]]
  }

}
