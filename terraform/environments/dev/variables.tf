variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-cicd-platform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "ecr_repository_url" {
  description = "ECR repository URL created by the bootstrap"
  type        = string
}

variable "container_image" {
  description = "Container image used by ECS"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "availability_zones" {
  description = "Availability Zones used by the development environment"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones must be provided."
  }
}