#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Docker installation on Red Hat..."

# 1. Update the system packages
echo "Updating system packages..."
sudo dnf -y update

# 2. Install the 'dnf-utils' package
echo "Installing dnf-utils..."
sudo dnf install -y dnf-utils

# 3. Add the Docker repository
echo "Adding the official Docker repository..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# 4. Install Docker Engine, containerd, and Docker Compose
echo "Installing Docker Engine, containerd, and Docker Compose..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Start and enable the Docker service
echo "Starting and enabling the Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# 6. Add the current user to the 'docker' group to run Docker commands without 'sudo'
echo "Adding current user to the 'docker' group..."
sudo usermod -aG docker "$USER"

# 7. Verify the installation
echo "Verifying Docker installation..."
if docker --version &> /dev/null; then
    echo "Docker has been installed successfully."
    echo "Please log out and log back in for the group changes to take effect."
else
    echo "Docker installation failed. Please check the logs for errors."
fi

echo "Docker installation script finished."