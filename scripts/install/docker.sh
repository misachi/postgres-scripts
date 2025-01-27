#/bin/sh

set -e

echo "Begin docker installation"
sudo apt-get update
for pkg in docker.io docker-compose docker-compose-v2 containerd runc; do sudo apt-get remove $pkg; done

echo  "Add Docker's official GPG key:"
sudo apt-get update > /dev/null
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc > /dev/null

echo "Add the repository to Apt sources:"

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update > /dev/null

echo "Install docker and dependencies"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Post Installation for docker"
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
echo "Installation complete"
