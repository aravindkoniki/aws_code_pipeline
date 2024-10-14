data "aws_caller_identity" current {}
data "aws_region" current {}
data "aws_partition" current {}

data "aws_codestarconnections_connection" "connection" {
  arn = "arn:aws:codeconnections:eu-west-1:947500280148:connection/1cdf789f-509e-44a5-bf5d-ea29d839a59d" # personal aws account
  #arn = "arn:aws:codeconnections:eu-central-1:416557291090:connection/b5c3e99d-2931-4631-bdcf-c6557b989b78" #pt-bl-test
}

# KMS
data "aws_iam_policy_document" "kms_key_policy_doc" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow access for Key Administrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.codepipeline_build_role.arn
      ]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.codepipeline_build_role.arn
      ]
    }
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.codepipeline_build_role.arn
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

# codebuild and codepipeline trust
data "aws_iam_policy_document" "code_pipeline_build_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}


# codebuild and codepipeline policy 
data "aws_iam_policy_document" "code_pipeline_build_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:ListBuckets"
    ]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}",
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketVersioning"
    ]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}",
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = ["${aws_kms_key.encryption_key.arn}"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects"
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/${var.project_name}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:*",
    ]
    resources = [
      data.aws_codestarconnections_connection.connection.arn
    ]
  }

  # for deploying Infrastructure on code
  statement {
    effect = "Allow"

    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:ListRoleTags",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:ListPolicyTags",
      "iam:ListPolicyVersions",
      "iam:ListAttachedGroupPolicies",
      "iam:ListPolicies",
      "iam:ListInstanceProfilesForRole"
    ]

    resources = ["*"]
  }
  # for terraform state access
  statement {
    actions = ["s3:ListBucket"]
    effect  = "Allow"

    resources = ["arn:aws:s3:::aravindkoniki-tfstate-28092024"]
  }
  # for terraform state access
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    effect = "Allow"

    resources = ["arn:aws:s3:::aravindkoniki-tfstate-28092024/*"]
  }
  # for terraform state access
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    effect = "Allow"

    resources = ["arn:aws:dynamodb:eu-west-1:947500280148:table/terraformstate-locks-tfstate-05082023"]
  }


  # cross account IAM Role
}

# for deploying Infrastructure on code
data "aws_iam_policy_document" "code_pipeline_build_deployment_policy" {
  statement {
    effect = "Allow"

    actions = [
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:ListRoleTags",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:ListPolicyTags",
      "iam:ListPolicyVersions",
      "iam:ListAttachedGroupPolicies",
      "iam:ListPolicies",
      "iam:ListInstanceProfilesForRole"
    ]

    resources = ["*"]
  }
  # for terraform state access
  statement {
    actions = ["s3:ListBucket"]
    effect  = "Allow"

    resources = ["arn:aws:s3:::aravindkoniki-tfstate-28092024"]
  }
  # for terraform state access
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    effect = "Allow"

    resources = ["arn:aws:s3:::aravindkoniki-tfstate-28092024/*"]
  }
  # for terraform state access
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    effect = "Allow"

    resources = ["arn:aws:dynamodb:eu-west-1:947500280148:table/terraformstate-locks-tfstate-05082023"]
  }
}

# cross account
data "aws_iam_policy_document" "cross_role_policy_dev_account" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::767847069565:role/code-pipeline-dev-account-role"] # create this IAM Role dev account

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["cross_account_codepipeline"]
    }
  }
}
