terraform {
  backend "s3" {
    bucket       = "aws-cicd-platform-tf-state-20100"
    key          = "environments/dev/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}