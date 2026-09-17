# Security Model and Deliberate Trade-offs

This project applies security controls appropriate for a low-cost development
environment.

## Implemented controls

- GitHub Actions authenticates to AWS through OIDC.
- No long-lived AWS access keys are stored in GitHub.
- The Terraform state bucket is private, versioned and encrypted.
- ECR uses immutable image tags and encryption.
- ECS containers use a read-only root filesystem.
- ECS traffic is accepted only from the ALB security group.
- Container and Terraform security scans run in CI.

## Development-environment trade-offs

The ALB is publicly reachable over HTTP so the demonstration can be accessed
without purchasing or configuring a domain name and TLS certificate.

The ECS task uses a public IP to avoid a NAT Gateway and its recurring cost.
This is acceptable for a short-lived demonstration environment, but production
tasks should run in private subnets using NAT Gateway or VPC endpoints.

WAF, VPC Flow Logs, cross-region state replication and ALB access logging are
not enabled in this low-cost version. They should be considered for a
production deployment.

The environment is intentionally destroyable after testing.
