#!/usr/bin/env bash
# Lab 7 Setup Script for Pulumi Static Website Deployment

set -e

echo "🚀 Lab 7: Pulumi Static Website Setup"
echo "========================================"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v pulumi &> /dev/null; then
    echo -e "${RED}❌ Pulumi CLI not found. Please install it:${NC}"
    echo "   https://www.pulumi.com/docs/get-started/install/"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Please install it:${NC}"
    echo "   https://nodejs.org/"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found. Please install it.${NC}"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo -e "${YELLOW}⚠️  AWS CLI not found. Some features may not work.${NC}"
fi

echo -e "${GREEN}✅ All prerequisites found${NC}"

# Get Pulumi version
PULUMI_VERSION=$(pulumi version)
NODE_VERSION=$(node --version)
echo -e "   Pulumi: ${GREEN}${PULUMI_VERSION}${NC}"
echo -e "   Node.js: ${GREEN}${NODE_VERSION}${NC}"

# Check Pulumi login
echo -e "\n${YELLOW}🔐 Checking Pulumi authentication...${NC}"
if pulumi whoami &> /dev/null; then
    PULUMI_USER=$(pulumi whoami)
    echo -e "${GREEN}✅ Logged in as: ${PULUMI_USER}${NC}"
else
    echo -e "${YELLOW}⚠️  Not logged into Pulumi. Please run: pulumi login${NC}"
    read -p "Do you want to login now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pulumi login
    fi
fi

# Initialize ppinfra stack
echo -e "\n${YELLOW}📦 Setting up Pulumi project...${NC}"

cd ppinfra

# Check if stack exists
if pulumi stack ls 2>/dev/null | grep -q "dev"; then
    echo -e "${GREEN}✅ Stack 'dev' already exists${NC}"
    STACK_OPERATION="select"
else
    echo -e "Creating new stack 'dev'..."
    pulumi stack init dev
    STACK_OPERATION="created"
fi

# Select dev stack
pulumi stack select dev

# Install dependencies
echo -e "\n${YELLOW}📚 Installing npm dependencies...${NC}"
npm ci

# Set configuration
echo -e "\n${YELLOW}⚙️  Configuring stack...${NC}"

pulumi config set aws:region us-east-1 --stack dev
pulumi config set myworkshop:path ./www --stack dev
pulumi config set myworkshop:indexDocument index.html --stack dev
pulumi config set myworkshop:errorDocument error.html --stack dev

echo -e "${GREEN}✅ Configuration complete${NC}"

# Show current configuration
echo -e "\n${YELLOW}📋 Current configuration:${NC}"
pulumi config show --stack dev

# Offer to run preview
echo -e "\n${YELLOW}🔍 Ready to preview deployment?${NC}"
read -p "Run 'pulumi preview'? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Previewing changes...${NC}"
    pulumi preview --stack dev
fi

echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "  1. Review and update GitHub Secrets:"
echo "     - PULUMI_ACCESS_TOKEN"
echo "     - AWS_ROLE_ARN"
echo ""
echo "  2. Configure AWS OIDC provider for GitHub Actions"
echo ""
echo "  3. Deploy: git push origin main"
echo ""
echo "  4. Destroy: gh workflow run destroy.yml -f confirm_destroy=confirm"
echo ""
echo "For more info, see: LAB7_SETUP.md"

cd ..
