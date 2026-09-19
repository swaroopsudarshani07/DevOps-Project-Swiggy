#!/bin/bash
# Update system
sudo apt update -y

# Install Temurin JDK 21 (Adoptium)
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update -y
sudo apt install temurin-21-jdk -y
/usr/bin/java --version

# Clean old Jenkins repo/key
sudo rm -f /etc/apt/sources.list.d/jenkins.list /usr/share/keyrings/jenkins-keyring.asc

# Add Jenkins LTS repo with the NEW 2026 key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins LTS
sudo apt-get update -y
sudo apt-get install jenkins -y

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins


# Install Docker (current stable: 29.1.3)
sudo apt-get update
sudo apt-get install docker.io=29.1.3-0ubuntu3~24.04.2 -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

# Run SonarQube LTS Community container
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install Trivy (current stable: 0.74.0)
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy=0.74.0 -y

