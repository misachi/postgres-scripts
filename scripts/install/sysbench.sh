#/bin/sh
set -e

echo "Installing Sysbench"
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench
