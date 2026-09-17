variable "aws_region" {
  description = "AWS region used by the platform"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project name used in AWS resource names"
  type        = string
  default     = "aws-cicd-platform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}

variable "github_owner" {
  description = "GitHub user or organisation owning the repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
}

variable "github_repo_id" {
  description = "Immutable GitHub repository ID"
  type        = string
}