#!/bin/bash
#
# Install and configures Docker & Docker Compose
# Written by Saurav Mitra (saurav.karate@gmail.com)
#
# Written for Ubuntu 18.10 LTS
# Version 0.1
#
# No implicit or explicit guarantee assured, use in your own risk
#

SITEUSER='appuser'

set -o pipefail
__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"
export DEBIAN_FRONTEND=noninteractive

# check if root, if not get out
if [ `id -u` != "0" ]; then
  echo "Run this ${__FILE__} as root"
  exit -1
else
  echo "Initiating Setup script as root"
fi

apt-get --assume-yes --quiet install language-pack-en >> /dev/null
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8                                  >> /dev/null
dpkg-reconfigure locales                                >> /dev/null
apt-get --assume-yes --quiet  update					>> /dev/null

echo 'LC_ALL="en_US.UTF-8"' 							>> /etc/environment
echo "Adding some swap space..."
fallocate -l 1G /swapfile # creates SWAP space
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sysctl vm.swappiness=10
sysctl vm.vfs_cache_pressure=50
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf

apt-get --assume-yes --quiet update					>> /dev/null
apt-get --assume-yes --quiet install apt-transport-https ca-certificates curl software-properties-common	>> /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"	2>&1 1> /dev/null
apt-get --assume-yes --quiet  update					>> /dev/null
apt-get --assume-yes --quiet install docker-ce 			>> /dev/null
systemctl restart docker

curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

groupadd -g 7000 ${SITEUSER}
useradd -u 7000 -ms /bin/bash -g ${SITEUSER} ${SITEUSER}
usermod -aG docker ${SITEUSER}

apt-get --assume-yes --quiet install unzip