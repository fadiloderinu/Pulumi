# Pulumi Lab 7: Static Website with S3, CloudFront, and CI/CD

This lab demonstrates deploying a static website on AWS using Pulumi with automated CI/CD pipelines and ESC-based authentication.

## Prerequisites

1. **Pulumi Cloud Account**: https://app.pulumi.com/
2. **GitHub Account** with this repository
3. **AWS Account** with appropriate IAM permissions
4. **Node.js 18+** and npm

## Setup Instructions

### 1. Pulumi Cloud Account & Authentication

```bash
# Login to Pulumi
pulumi login

# Create API token at https://app.pulumi.com/account/tokens
# Use it when prompted
```

### 2. GitHub Configuration

#### Create GitHub Secrets:

1. **PULUMI_ACCESS_TOKEN**
   - Generate at: https://app.pulumi.com/account/tokens
   - Add to GitHub Secrets: Settings → Secrets and variables → Actions

2. **AWS_ROLE_ARN**
   - ARN of the IAM role for OIDC authentication
   - Example: `arn:aws:iam::123456789012:role/github-actions-role`

3. **PULUMI_PASSPHRASE** (optional)
   - For ESC deployment

#### GitHub OIDC Setup for AWS:

1. Add GitHub as OIDC provider in AWS IAM
2. Create IAM role with trust relationship to GitHub:
   ```json
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
       },
       "StringLike": {
         "token.actions.githubusercontent.com:sub": "repo:GITHUB_ORG/REPO_NAME:*"
       }
     }
   }
   ```

### 3. Initialize Pulumi Stack

```bash
cd ppinfra

# Create dev stack
pulumi stack init dev

# Configure AWS region
pulumi config set aws:region us-east-1

# Configure website path
pulumi config set myworkshop:path ./www
```

### 4. Local Testing

```bash
cd ppinfra

# Install dependencies
npm install

# Preview changes
pulumi preview

# Deploy to AWS
pulumi up

# Destroy resources
pulumi destroy
```

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy.yml          # Deploy pipeline
│       └── destroy.yml         # Destroy pipeline
├── ppinfra/
│   ├── index.ts               # Pulumi IaC code
│   ├── package.json           # Dependencies
│   ├── tsconfig.json          # TypeScript config
│   ├── Pulumi.yaml            # Project config
│   ├── Pulumi.dev.yaml        # Stack config
│   └── www/
│       ├── index.html         # Website content
│       └── error.html         # Error page
├── Pulumi.esc.yaml            # ESC configuration
└── README.md
```

## GitHub Actions Workflows

### Deploy Pipeline (`deploy.yml`)

- Triggers on push to `main` branch
- Configures AWS credentials via OIDC
- Runs `pulumi preview` and `pulumi up`
- Exports stack outputs
- Uploads deployment logs

**Trigger:**
```bash
git push origin main
```

### Destroy Pipeline (`destroy.yml`)

- Manual workflow dispatch with confirmation
- Requires "confirm" input to prevent accidents
- Configures AWS credentials via OIDC
- Runs `pulumi destroy --yes --remove`
- Uploads destruction logs

**Trigger:**
```bash
# Via GitHub UI: Actions → Destroy Static Website → Run workflow
# Or use GitHub CLI:
gh workflow run destroy.yml -f confirm_destroy=confirm
```

## Pulumi ESC (Environments, Secrets, and Credentials)

ESC provides:
- Centralized secrets management
- OIDC-based AWS authentication
- Environment-specific configurations
- No hardcoded credentials in workflows

### Configure ESC Environment

1. Create environment at: https://app.pulumi.com/account/organizations
2. Add secrets for `AWS_ROLE_ARN` and `PULUMI_PASSPHRASE`
3. Reference in GitHub Actions:
   ```yaml
   - name: Set ESC environment
     run: pulumi env open dev --format json > $GITHUB_ENV
   ```

## Deployment Workflow

```
1. Code Push to main
   ↓
2. GitHub Actions triggers deploy.yml
   ↓
3. OIDC authenticates with AWS
   ↓
4. Pulumi CLI installed
   ↓
5. Dependencies installed (npm ci)
   ↓
6. Pulumi preview runs
   ↓
7. Pulumi up deploys resources:
   - S3 bucket created
   - Website config applied
   - Website files synced
   - CloudFront distribution created
   ↓
8. Stack outputs exported
   ↓
9. Logs uploaded to artifacts
```

## Verification

### Check Pulumi Dashboard

1. Visit: https://app.pulumi.com/fadiloderinu/myworkshop/dev/resources
2. View deployed resources:
   - S3 Bucket
   - CloudFront Distribution
   - Stack outputs (CDN URL, Origin URL)

### Access Website

After deployment, visit the CloudFront URL from stack outputs:
```
https://<cloudfront-domain-name>.cloudfront.net
```

### View GitHub Actions

1. Repository → Actions tab
2. Select workflow run
3. View logs and artifacts

## Troubleshooting

### Pulumi Login Error
```bash
pulumi logout
pulumi login https://api.pulumi.com
```

### AWS Authentication Fails
- Verify OIDC provider is configured in AWS IAM
- Check GitHub Secrets are set correctly
- Ensure IAM role has S3 and CloudFront permissions

### Stack Already Exists
```bash
pulumi stack select dev
# Or force remove:
pulumi stack rm dev
```

### Permission Denied on Files
- Grant execute permission: `chmod +x ./scripts/*.sh`
- Ensure GitHub Actions has proper permissions

## Screenshots Evidence

Capture and save the following:

1. **Pulumi Dashboard** - Stack details page showing all resources
2. **GitHub Actions Deploy** - Successful workflow run with logs
3. **GitHub Actions Destroy** - Successful destruction with confirmation
4. **Pulumi ESC** - Environment configuration with OIDC evidence
5. **AWS Console** - CloudFront distribution and S3 bucket created
6. **Website Access** - Live website accessible via CloudFront URL

## References

- Pulumi Docs: https://www.pulumi.com/docs/
- AWS S3 and CloudFront: https://www.pulumi.com/docs/guides/using-pulumi-cloudformation/
- GitHub OIDC: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- Pulumi ESC: https://www.pulumi.com/docs/esc/

## Lab 7 Checklist

- [ ] Pulumi Cloud Account created
- [ ] GitHub integration setup
- [ ] GitHub Secrets configured (PULUMI_ACCESS_TOKEN, AWS_ROLE_ARN)
- [ ] AWS OIDC provider configured
- [ ] Deploy workflow runs successfully
- [ ] Website deployed to S3 + CloudFront
- [ ] Destroy workflow runs successfully
- [ ] Pulumi ESC configured with OIDC
- [ ] Screenshots captured:
  - [ ] Pulumi dashboard (5 marks)
  - [ ] GitHub Actions deploy (5 marks)
  - [ ] GitHub Actions destroy (10 marks)
  - [ ] Pulumi ESC with OIDC (20 marks)
