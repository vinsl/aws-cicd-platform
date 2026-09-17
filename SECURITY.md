# Security Policy

## Scope

This policy applies to the source code, Terraform configuration, Docker image and GitHub Actions workflows in this repository.

## Supported versions

This is a demonstration project. Only the latest version on the `main` branch is actively maintained.

| Version | Supported |
|---|---|
| `main` | Yes |
| Older commits and branches | No |

## Reporting a vulnerability

Please do not disclose security vulnerabilities through public GitHub issues or pull requests.

Report vulnerabilities privately through GitHub's private vulnerability reporting feature or by contacting the repository owner directly.

Please include:

- a description of the issue;
- the affected file or component;
- reproduction steps;
- the potential impact;
- a suggested remediation, if available.

## Security practices

This project uses:

- GitHub Actions OIDC instead of long-lived AWS access keys;
- least-privilege IAM permissions;
- Gitleaks for secret detection;
- Checkov for Terraform security checks;
- Trivy for container vulnerability scanning;
- encrypted and versioned Terraform state storage;
- immutable ECR image tags;
- a post-deployment health check.

## Secret handling

Never commit:

- AWS access keys;
- private keys;
- `.env` files;
- Terraform state files;
- personal Terraform variable files containing sensitive values.

If a credential is accidentally committed, revoke or rotate it immediately even if the commit is later removed.