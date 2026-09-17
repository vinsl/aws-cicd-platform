# Rollback Procedure

## When to roll back

Roll back when:

- the ECS service fails to stabilize;
- the application returns errors;
- the `/health` endpoint fails;
- the new image introduces a regression;
- the deployment causes an unacceptable availability problem.

## Identify task definition revisions

List active revisions:

```bash
aws ecs list-task-definitions \
  --family-prefix aws-cicd-platform-dev-task \
  --status ACTIVE \
  --sort DESC \
  --region eu-west-3
```

Inspect a revision:

```bash
aws ecs describe-task-definition \
  --task-definition aws-cicd-platform-dev-task:<REVISION> \
  --region eu-west-3
```

Use the revision that was known to work before the failed deployment.

## Update the ECS service

```bash
aws ecs update-service \
  --cluster aws-cicd-platform-dev-cluster \
  --service aws-cicd-platform-dev-service \
  --task-definition aws-cicd-platform-dev-task:<PREVIOUS_REVISION> \
  --force-new-deployment \
  --region eu-west-3
```

Wait for stability:

```bash
aws ecs wait services-stable \
  --cluster aws-cicd-platform-dev-cluster \
  --services aws-cicd-platform-dev-service \
  --region eu-west-3
```

## Validate the rollback

Retrieve the load balancer DNS name:

```bash
aws elbv2 describe-load-balancers \
  --names aws-cicd-platform-dev-alb \
  --region eu-west-3 \
  --query 'LoadBalancers.DNSName' \
  --output text
```

Then test:

```bash
curl --fail http://<ALB_DNS_NAME>/health
```

The expected response is HTTP 200 with:

```json
{"status":"ok"}
```

## After rollback

1. Keep the failed task definition revision for investigation.
2. Check ECS service events and CloudWatch logs.
3. Identify the source commit associated with the failed image tag.
4. Fix the issue in a new branch.
5. Open a new Pull Request.
6. Do not manually edit the production workflow to bypass the validation gates.