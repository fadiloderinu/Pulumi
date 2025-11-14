# Pulumi Static Website Deployment

This repository contains a complete Pulumi Infrastructure-as-Code (IaC) project for deploying a static website on AWS using S3 and CloudFront with automated CI/CD pipelines.

## 🚀 Lab 7: Complete Exercise Solution

This project implements all requirements for Lab 7, including:

- ✅ Pulumi Cloud Account integration
- ✅ GitHub repository setup with version control
- ✅ Static website deployment (S3 + CloudFront)
- ✅ GitHub Actions CI/CD pipelines (deploy & destroy)
- ✅ Pulumi ESC with OIDC-based AWS authentication

## 📋 Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── deploy.yml                # Automated deployment pipeline
│       └── destroy.yml               # Safe destruction pipeline
├── ppinfra/                          # Pulumi project
│   ├── index.ts                      # Infrastructure code
│   ├── package.json                  # Node.js dependencies
│   ├── tsconfig.json                 # TypeScript configuration
│   ├── Pulumi.yaml                   # Project definition
│   ├── Pulumi.dev.yaml               # Stack configuration
│   └── www/                          # Website content
│       ├── index.html                # Homepage
│       └── error.html                # Error page
├── Pulumi.esc.yaml                   # Environments, Secrets & Credentials
├── setup.sh                          # Setup script (Linux/macOS)
├── setup.bat                         # Setup script (Windows)
├── LAB7_SETUP.md                     # Detailed setup instructions
└── README.md                         # This file
```

## 🛠️ Quick Start

### 1. Prerequisites

- Pulumi CLI 3.207.0+
- Node.js 18+ and npm
- Git
- AWS Account with appropriate IAM permissions
- GitHub Account

### 2. Install Pulumi

**Option A: Windows (Chocolatey)**
```powershell
choco install pulumi -y
```

**Option B: Official Installer (all platforms)**
```bash
# Linux/macOS
curl -fsSL https://get.pulumi.com | sh

# Windows PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://get.pulumi.com/install.ps1'))
```

### 3. Setup Project

**Linux/macOS:**
```bash
bash setup.sh
```

**Windows:**
```cmd
setup.bat
```

Or manually:
```bash
cd ppinfra
npm install
pulumi login
pulumi stack init dev
pulumi config set aws:region us-east-1
pulumi preview
```

### 4. Deploy

**Local deployment:**
```bash
cd ppinfra
pulumi up
```

**Automated deployment via GitHub Actions:**
```bash
git push origin main
# Watch: https://github.com/YOUR_ORG/Pulumi/actions
```

### 5. Destroy

**Local destruction:**
```bash
cd ppinfra
pulumi destroy
```

**Safe destruction via GitHub Actions:**
```bash
gh workflow run destroy.yml -f confirm_destroy=confirm
# Confirm when prompted
```

## 🔐 GitHub Actions & OIDC Setup

### Required GitHub Secrets

1. **PULUMI_ACCESS_TOKEN**
   - Generate at: https://app.pulumi.com/account/tokens
   - Add to GitHub: Settings → Secrets and variables → Actions

2. **AWS_ROLE_ARN**
   - IAM role ARN for OIDC federation
   - Example: `arn:aws:iam::123456789012:role/github-actions-role`

### AWS OIDC Configuration

Create IAM role with GitHub OIDC provider:

```json
{
  "Version": "2012-10-17",
  "Statement": [
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
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/Pulumi:*"
        }
      }
    }
  ]
}
```

## 🌐 Accessing Your Website

After deployment, visit the CloudFront URL:

```
https://d1234abcd.cloudfront.net
```

Stack outputs available via:
```bash
pulumi stack output cdnURL
pulumi stack output originURL
```

## 📊 Monitoring & Verification

### Pulumi Dashboard
- View stack: https://app.pulumi.com/fadiloderinu/myworkshop/dev/resources
- Monitor deployments and rollbacks
- Track resource history

### GitHub Actions
- Deploy logs: https://github.com/YOUR_ORG/Pulumi/actions/workflows/deploy.yml
- Destroy logs: https://github.com/YOUR_ORG/Pulumi/actions/workflows/destroy.yml

### AWS Console
- S3 bucket: https://console.aws.amazon.com/s3/
- CloudFront distribution: https://console.aws.amazon.com/cloudfront/

## 🔑 Pulumi ESC (Environments, Secrets & Credentials)

ESC provides centralized secret management with OIDC support:

1. Create environment: https://app.pulumi.com/account/environments
2. Configure AWS OIDC login with role ARN
3. Reference in GitHub Actions (see `Pulumi.esc.yaml`)

**Benefits:**
- No hardcoded secrets in workflows
- OIDC-based temporary credentials
- Environment-specific configurations
- Audit trail of all access

## 📝 Infrastructure Details

### AWS Resources Deployed

1. **S3 Bucket**
   - Static website hosting enabled
   - Public read access for website files
   - Error page configuration

2. **CloudFront Distribution**
   - CDN for global content delivery
   - HTTPS by default
   - Gzip compression
   - Custom error handling

3. **Synced Folder**
   - Automatic website content sync to S3
   - Public ACL for web accessibility

## 🧪 Testing Workflow

```bash
# 1. Make changes to website
echo "<h1>Updated!</h1>" >> ppinfra/www/index.html

# 2. Preview changes
cd ppinfra && pulumi preview

# 3. Apply changes
pulumi up

# 4. Verify website
curl https://$(pulumi stack output cdnURL | sed 's|https://||')

# 5. Push to trigger GitHub Actions
git add -A && git commit -m "Update website" && git push
```

## 🐛 Troubleshooting

### Pulumi Login Issues
```bash
pulumi logout
pulumi login
```

### Stack Already Exists
```bash
pulumi stack select dev
# Or remove and recreate:
pulumi stack rm dev
pulumi stack init dev
```

### AWS Credentials Not Found
- Verify AWS credentials are configured: `aws sts get-caller-identity`
- Check IAM permissions for S3, CloudFront, and IAM roles
- For GitHub Actions, verify OIDC role ARN is correct

### Website Not Accessible
- Check CloudFront distribution is enabled (wait 2-3 minutes after creation)
- Verify S3 bucket public access is allowed
- Check error page in CloudFront distribution

## 📚 Resources

- **Pulumi Documentation**: https://www.pulumi.com/docs/
- **AWS S3 & CloudFront**: https://www.pulumi.com/docs/aws/
- **GitHub OIDC**: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- **Pulumi ESC**: https://www.pulumi.com/docs/esc/
- **TypeScript for Pulumi**: https://www.pulumi.com/docs/languages-sdks/typescript/

## 📋 Lab 7 Submission Checklist

### Part A: Pulumi Dashboard Screenshot (5 marks)
- [ ] Access https://app.pulumi.com/fadiloderinu/myworkshop/dev/resources
- [ ] Screenshot shows stack details with all resources
- [ ] Screenshot includes resource outputs (CDN URL, Origin URL)

### Part B: GitHub Actions Deploy Screenshot (5 marks)
- [ ] Navigate to Actions → deploy.yml workflow
- [ ] Screenshot shows successful workflow run
- [ ] Screenshot includes deployment logs and artifacts

### Part C: GitHub Actions Destroy Screenshot (10 marks)
- [ ] Navigate to Actions → destroy.yml workflow
- [ ] Trigger with: `gh workflow run destroy.yml -f confirm_destroy=confirm`
- [ ] Screenshot shows successful destruction workflow
- [ ] Screenshot includes destruction logs and confirmation

### Part D: Pulumi ESC & OIDC Setup (20 marks)
- [ ] Configure ESC environment at https://app.pulumi.com/account/organizations
- [ ] Set up AWS OIDC provider in IAM
- [ ] Screenshot shows ESC environment configuration
- [ ] Screenshot shows OIDC role and trust relationship in AWS IAM
- [ ] Screenshot shows GitHub Actions using OIDC credentials (no token in logs)
- [ ] Screenshot shows `aws-actions/configure-aws-credentials@v4` step successful

## 🤝 Contributing

Feel free to extend this project:

- Add custom domain with Route 53
- Implement CloudFront caching policies
- Add Lambda@Edge for dynamic content
- Integrate with CI/CD for website builds
- Add monitoring with CloudWatch

## 📄 License

MIT License

## 💬 Support

For issues or questions:
1. Check [LAB7_SETUP.md](LAB7_SETUP.md) for detailed instructions
2. Review [Pulumi documentation](https://www.pulumi.com/docs/)
3. Check GitHub Actions logs for deployment errors
4. Verify AWS IAM permissions and OIDC configuration

---

**Created for Lab 7 Exercise**  
Static Website Deployment with Pulumi, AWS, and GitHub Actions
