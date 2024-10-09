# random string
resource "random_string" "default" {
  length  = 4
  special = false
}

#s3 bucket for artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "ak-codepipeline-bucket-${lower(random_string.default.result)}"
  acl    = "private"
}

# KMS
resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  policy                  = data.aws_iam_policy_document.kms_key_policy_doc.json
  enable_key_rotation     = true
  tags                    = var.tags
}

# IAM
resource "aws_iam_role" "codepipeline_build_role" {
  name               = var.code_pipeline_build_role_name
  assume_role_policy = data.aws_iam_policy_document.code_pipeline_build_assume_role_policy.json
  tags               = var.tags
}

# code build policy
resource "aws_iam_policy" "code_pipeline_build_policy" {
  name        = "${var.code_pipeline_build_role_name}-policy"
  description = "Policy to allow codepipeline to execute"
  policy      = data.aws_iam_policy_document.code_pipeline_build_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_role_attach" {
  role       = aws_iam_role.codepipeline_build_role.name
  policy_arn = aws_iam_policy.code_pipeline_build_policy.arn
}

# code build deployment policy
resource "aws_iam_policy" "code_pipeline_deployment_policy" {
  name        = "${var.code_pipeline_build_role_name}-deployment-policy"
  description = "Policy to allow codepipeline deployment policy to execute"
  policy      = data.aws_iam_policy_document.code_pipeline_build_deployment_policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_deployment_role_attach" {
  role       = aws_iam_role.codepipeline_build_role.name
  policy_arn = aws_iam_policy.code_pipeline_deployment_policy.arn
}

# code build assume role policy
resource "aws_iam_policy" "code_pipeline_dev_deployment_policy" {
  name        = "${var.code_pipeline_build_role_name}-dev-deployment-policy"
  description = "Policy to allow codepipeline to deploy into dev account"
  policy      = data.aws_iam_policy_document.cross_role_policy_dev_account.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_dev_deployment_role_attach" {
  role       = aws_iam_role.codepipeline_build_role.name
  policy_arn = aws_iam_policy.code_pipeline_dev_deployment_policy.arn
}


# code build
module "codebuild" {
  source         = "./modules/codebuild"
  project_name   = var.project_name
  role_arn       = aws_iam_role.codepipeline_build_role.arn
  kms_key_arn    = aws_kms_key.encryption_key.arn
  build_projects = var.build_projects
}


# code pipeline
module "codepipeline" {
  source                = "./modules/codepipeline"
  project_name          = var.project_name
  connection_arn        = data.aws_codestarconnections_connection.connection.arn
  full_repository_id    = var.full_repository_id
  s3_bucket_name        = aws_s3_bucket.codepipeline_bucket.bucket
  codepipeline_role_arn = aws_iam_role.codepipeline_build_role.arn
  kms_key_arn           = aws_kms_key.encryption_key.arn
  stages                = var.stages

}
