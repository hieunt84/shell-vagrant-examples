#!/bin/bash

##########################################################################################
# SECTION 1: PREPARE

# update system
sudo -i
sleep 1
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
hostnamectl set-hostname node1

# config file host
cat >> "/etc/hosts" <<END
172.20.10.199 node1
172.20.10.200 node2
172.20.10.201 node3
172.20.10.198 controlpanel
END

# config network

##########################################################################################
# SECTION 2: INSTALL ANSIBLE AND DEPENDENCIES

yum -y install epel-release 
yum -y update
yum -y ansible

#########################################################################################
# SECTION 3: CONFIG ANSIBLE

# Config hosts
cat >> "/etc/ansible/hosts" <<END
[srv-db]
node1 ansible_host=172.20.10.199
node2 ansible_host=172.20.10.200
node3 ansible_host=172.20.10.201
controlpanel ansible_host=127.0.0.1
END

#########################################################################################
# SECTION 4: FINISHED
printf "Server restart in 5 seconds\n"
sleep 5
reboot