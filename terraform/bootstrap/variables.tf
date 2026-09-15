variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name (used for naming resources)"
  type        = string
  default     = "dev"
}

variable "github_owner" {
  description = "GitHub owner (user or org), e.g. 'vincent-lucas'"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name, e.g. 'aws-cicd-platform'"
  type        = string
}