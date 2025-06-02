#!/bin/bash
# Installation script for Vagrant, Ansible, and Kubernetes tools in WSL2

set -e  # Exit on any error

echo "Updating package lists..."
sudo apt update

echo "Installing dependencies..."
sudo apt install -y curl apt-transport-https ca-certificates software-properties-common gnupg lsb-release wget

echo "Installing Vagrant..."
# Add HashiCorp GPG key and repository
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y vagrant

echo "Installing Ansible..."
sudo apt install -y ansible

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.32.4/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "Installing Helm..."
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

echo "Installing kubeadm client tools..."
# Create keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Download the Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install kubeadm
sudo apt-get update
sudo apt-get install -y kubeadm

# Install VirtualBox WSL driver
echo "For VirtualBox, you'll need to install it in Windows and configure WSL2 integration"
echo "See: https://www.virtualbox.org/wiki/Downloads"

echo "Installation complete!"

# ansible-playbook -u vagrant -i 172.30.144.1:2222, provision/finalization.yml -e "ansible_ssh_private_key_file=$(pwd)/.vagrant/machines/ctrl/virtualbox/private_key"