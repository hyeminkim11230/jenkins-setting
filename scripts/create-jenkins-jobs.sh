#!/bin/bash

# Jenkins Job 생성 스크립트
# Jenkins API를 사용하여 자동으로 Pipeline Job 생성

JENKINS_URL="${JENKINS_URL:-http://192.168.1.143:8080}"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_TOKEN="${JENKINS_TOKEN}"

if [ -z "$JENKINS_TOKEN" ]; then
    echo "❌ JENKINS_TOKEN 환경변수를 설정해주세요"
    echo "Jenkins → 사용자 설정 → API Token에서 토큰을 생성하세요"
    exit 1
fi

# Jenkins Job XML 템플릿
create_pipeline_job() {
    local JOB_NAME=$1
    local GIT_REPO=$2
    local JENKINSFILE_PATH=$3
    
    cat << EOF > /tmp/${JOB_NAME}-config.xml
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <actions/>
  <description>CI/CD Pipeline for ${JOB_NAME}</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <com.cloudbees.jenkins.GitHubPushTrigger plugin="github">
          <spec></spec>
        </com.cloudbees.jenkins.GitHubPushTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>30</daysToKeep>
        <numToKeep>50</numToKeep>
        <artifactDaysToKeep>-1</artifactDaysToKeep>
        <artifactNumToKeep>-1</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>${GIT_REPO}</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>${JENKINSFILE_PATH}</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

    # Jenkins Job 생성
    curl -X POST \
        -H "Content-Type: application/xml" \
        -u "${JENKINS_USER}:${JENKINS_TOKEN}" \
        -d "@/tmp/${JOB_NAME}-config.xml" \
        "${JENKINS_URL}/createItem?name=${JOB_NAME}"
    
    if [ $? -eq 0 ]; then
        echo "✅ Jenkins Job '${JOB_NAME}' 생성 완료"
    else
        echo "❌ Jenkins Job '${JOB_NAME}' 생성 실패"
    fi
    
    rm -f /tmp/${JOB_NAME}-config.xml
}

echo "🏗️ Jenkins Pipeline Jobs 생성 중..."

# Main deployment pipeline
create_pipeline_job \
    "fashion-api-deploy" \
    "https://github.com/hyeminkim11230/jenkins-setting.git" \
    "pipelines/Jenkinsfile"

# Rollback pipeline
create_pipeline_job \
    "fashion-api-rollback" \
    "https://github.com/hyeminkim11230/jenkins-setting.git" \
    "pipelines/Jenkinsfile.rollback"

echo "🎉 모든 Jenkins Jobs 생성 완료!"
echo "🌐 Jenkins 대시보드: ${JENKINS_URL}"
