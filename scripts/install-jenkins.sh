#!/bin/bash

# Jenkins 서버 설치 및 설정 스크립트
# Ubuntu Server에서 실행

set -e

echo "🏗️ Jenkins 서버 설치 시작..."

# 시스템 업데이트
echo "📦 시스템 패키지 업데이트..."
sudo apt update && sudo apt upgrade -y

# Java 11 설치
echo "☕ Java 11 설치..."
sudo apt install -y openjdk-11-jdk

# Docker 설치
echo "🐳 Docker 설치..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# Kubernetes CLI 설치
echo "☸️ kubectl 설치..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Jenkins 설치
echo "🏗️ Jenkins 설치..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# Jenkins 서비스 시작
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Jenkins 사용자 권한 설정
sudo usermod -aG docker jenkins

# Kubernetes 설정 복사
sudo mkdir -p /var/lib/jenkins/.kube
if [ -f ~/.kube/config ]; then
    sudo cp ~/.kube/config /var/lib/jenkins/.kube/
    sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
fi

# 방화벽 설정
sudo ufw allow 8080/tcp

echo "✅ Jenkins 설치 완료!"
echo "🌐 Jenkins 접속: http://$(hostname -I | awk '{print $1}'):8080"
echo "🔑 초기 비밀번호:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
