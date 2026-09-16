# aws-cicd-platform

Demonstration of a secure CI/CD pipeline from GitHub to AWS ECS Fargate:
- GitHub Actions with PR and main workflows
- OIDC-based AWS authentication (no long-lived keys)
- Terraform remote state and modular infrastructure
- Dockerised Flask app with `/health` endpoint deployed to ECS Fargate
- Integrated security tools (gitleaks, Trivy, tfsec/Checkov)

test