# Deployment Flow

## Pull Request

A Pull Request targeting `main` runs the CI workflow.

The workflow validates the application and infrastructure without accessing AWS:

```text
Checkout
  |
  v
Pytest and Ruff
  |
  v
Docker build
  |
  v
Terraform fmt and validate
  |
  v
Checkov
  |
  v
Gitleaks
  |
  v
Trivy
```

The Pull Request workflow has read-only repository permissions and does not use AWS credentials.

## Main branch deployment

After a change is merged into `main`, the deployment workflow starts:

```text
GitHub Actions
  |
  v
OIDC token
  |
  v
AWS STS AssumeRoleWithWebIdentity
  |
  v
Temporary AWS credentials
  |
  v
Docker build
  |
  v
Trivy scan
  |
  v
Push image to ECR
  |
  v
Register ECS task definition
  |
  v
Update ECS service
  |
  v
Wait for service stability
  |
  v
HTTP smoke test
```

## Image versioning

Every deployment uses the Git commit SHA:

```text
<account>.dkr.ecr.<region>.amazonaws.com/<repository>:<commit-sha>
```

This allows the running image to be traced to an exact source revision.

## Failure behavior

The pipeline stops if:

- AWS authentication fails;
- Docker build fails;
- Trivy detects blocking vulnerabilities;
- ECR push fails;
- ECS task definition registration fails;
- ECS service does not become stable;
- the `/health` endpoint does not return HTTP 200.

## Security boundary

The GitHub Actions role is trusted only for the expected GitHub repository and deployment branch.

The deployment role can interact with the resources required for the application deployment but does not receive general administrator permissions.