<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Jenkins CI/CD Repository Instructions

This repository contains Jenkins pipelines, deployment scripts, and configuration files for managing CI/CD processes across multiple projects.

## Key Guidelines:

1. **Pipeline Structure**: All Jenkinsfiles should follow the declarative pipeline syntax
2. **Environment Management**: Support for dev, staging, and production environments
3. **Security**: Use Jenkins credentials and Kubernetes secrets for sensitive data
4. **Monitoring**: Include health checks and monitoring integration
5. **Notifications**: Configure Slack/email notifications for build status
6. **Multi-project Support**: Design pipelines to be reusable across different projects

## Project Focus:
- Fashion Recommendation API deployment
- Kubernetes orchestration
- Docker containerization
- Automated testing and security scanning
- Infrastructure as Code principles
