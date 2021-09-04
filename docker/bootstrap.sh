#!/bin/bash
# Script deploy portainer with docker

##########################################################################################
# SECTION 1: PREPARE

# change root
sudo -i
sleep 2

# update system
yum clean all
yum -y update
sleep 1

# config timezone
timedatectl set-timezone Asia/Ho_Chi_Minh

# disable SELINUX
setenforce 0 
sed -i 's/enforcing/disabled/g' /etc/selinux/config

# disable firewall
systemctl stop firewalld
systemctl disable firewalld

# config hostname
hostnamectl set-hostname docker1

# config file host
cat >> "/etc/hosts" <<END
 172.20.10.10 docker1 docker1.hit.local
END

##########################################################################################
# SECTION 2: INSTALL Docker

# Install docker
curl -fsSL https://get.docker.com/ | sh
systemctl start docker
systemctl enable docker

#########################################################################################
# SECTION 3: DEPLOY portainer

# Tạo volume cho portainer
docker volume create portainer_data

# Tạo portainer container
docker run -d -p 9000:9000 --name=portainer --restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
portainer/portainer-ce
  
#########################################################################################
# SECTION 4: FINISHED

# config firwall
systemctl start firewalld
systemctl enable firewalld
# Open Port for link Portainer
sudo firewall-cmd --zone=public --permanent --add-port=2375/tcp
sudo firewall-cmd --reload
sudo systemctl restart firewalld

# notification
echo " DEPLOY COMPLETELY"