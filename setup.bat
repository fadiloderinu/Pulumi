@echo off
REM Lab 7 Setup Script for Pulumi Static Website Deployment (Windows)

setlocal enabledelayedexpansion

echo 🚀 Lab 7: Pulumi Static Website Setup
echo ========================================

REM Check prerequisites
echo.
echo 📋 Checking prerequisites...

where pulumi >nul 2>nul
if errorlevel 1 (
    echo ❌ Pulumi CLI not found. Please install it:
    echo    https://www.pulumi.com/docs/get-started/install/
    exit /b 1
)

where node >nul 2>nul
if errorlevel 1 (
    echo ❌ Node.js not found. Please install it:
    echo    https://nodejs.org/
    exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
    echo ❌ Git not found. Please install it.
    exit /b 1
)

echo ✅ All prerequisites found

REM Get versions
for /f "tokens=*" %%i in ('pulumi version') do set PULUMI_VERSION=%%i
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i

echo    Pulumi: %PULUMI_VERSION%
echo    Node.js: %NODE_VERSION%

REM Check Pulumi login
echo.
echo 🔐 Checking Pulumi authentication...

pulumi whoami >nul 2>nul
if errorlevel 1 (
    echo ⚠️  Not logged into Pulumi. Please run: pulumi login
    set /p LOGIN="Do you want to login now? (y/n): "
    if /i "!LOGIN!"=="y" (
        pulumi login
    )
) else (
    for /f "tokens=*" %%i in ('pulumi whoami') do set PULUMI_USER=%%i
    echo ✅ Logged in as: !PULUMI_USER!
)

REM Initialize ppinfra stack
echo.
echo 📦 Setting up Pulumi project...

cd ppinfra

REM Check if stack exists
pulumi stack ls 2>nul | find "dev" >nul 2>nul
if errorlevel 1 (
    echo Creating new stack 'dev'...
    call pulumi stack init dev
) else (
    echo ✅ Stack 'dev' already exists
)

REM Select dev stack
call pulumi stack select dev

REM Install dependencies
echo.
echo 📚 Installing npm dependencies...
call npm ci

REM Set configuration
echo.
echo ⚙️  Configuring stack...

call pulumi config set aws:region us-east-1 --stack dev
call pulumi config set myworkshop:path ./www --stack dev
call pulumi config set myworkshop:indexDocument index.html --stack dev
call pulumi config set myworkshop:errorDocument error.html --stack dev

echo ✅ Configuration complete

REM Show current configuration
echo.
echo 📋 Current configuration:
call pulumi config show --stack dev

REM Show summary
echo.
echo ✅ Setup complete!
echo.
echo 📝 Next steps:
echo    1. Review and update GitHub Secrets:
echo       - PULUMI_ACCESS_TOKEN
echo       - AWS_ROLE_ARN
echo.
echo    2. Configure AWS OIDC provider for GitHub Actions
echo.
echo    3. Deploy: git push origin main
echo.
echo    4. Destroy: gh workflow run destroy.yml -f confirm_destroy=confirm
echo.
echo For more info, see: LAB7_SETUP.md

cd ..
endlocal
