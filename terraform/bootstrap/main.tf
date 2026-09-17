data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_state_kms" {
  statement {
    sid    = "EnableAccountRootUserPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecr_kms" {
  statement {
    sid    = "EnableAccountRootUserPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = {
    Name        = "${var.project_name}-terraform-state"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for ${var.project_name} Terraform state"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.terraform_state_kms.json

  tags = {
    Name        = "${var.project_name}-state-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}


resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action   = "s3:*"
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "ecr" {
  description             = "KMS key for ${var.project_name} ECR repository"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ecr_kms.json

  tags = {
    Name        = "${var.project_name}-ecr-kms"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${var.project_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name        = "${var.project_name}-app"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name      = "${var.project_name}-github-oidc"
    ManagedBy = "Terraform"
  }
}


resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "GitHubActionsMainBranch"
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main",
              "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })


  tags = {
    Name        = "${var.project_name}-github-actions"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "github_actions_deployment" {
  name = "${var.project_name}-github-actions-deployment-${var.environment}"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EcrLogin"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "EcrPushImage"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = aws_ecr_repository.app.arn
      },
      {
        Sid    = "EcsDeployment"
        Effect = "Allow"

        Action = [
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:UpdateService"
        ]

        Resource = [
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.project_name}-${var.environment}-task:*",
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.project_name}-${var.environment}-cluster/${var.project_name}-${var.environment}-service"
        ]
      },
      {
        Sid    = "EcsRegisterTaskDefinition"
        Effect = "Allow"

        Action = [
          "ecs:RegisterTaskDefinition"
        ]

        Resource = "*"
      },
      {
        Sid    = "LoadBalancerReadOnly"
        Effect = "Allow"

        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth"
        ]

        Resource = "*"
      }
    ]
  })
}