#!/bin/bash
# BEGIN
# Pretask
sudo -i
sleep 1
timedatectl set-timezone Asia/Ho_Chi_Minh
yum clean all
yum -y update
sleep 1

#disable SELINUX
setenforce 0 
sed -i 's/enforcing/disabled/g' /etc/selinux/config

#disable firewall
systemctl stop firewalld
systemctl disable firewalld

##########################################################################################
# I.Install Ansible
yum -y install epel-release 
yum -y update
yum -y install ansible

# II.Config hosts
cat >> "/etc/ansible/hosts" <<END
[srv-db]
node_1 ansible_host=172.20.10.199
node_2 ansible_host=172.20.10.200
node_3 ansible_host=172.20.10.201
END

# Config ssh key

#Save info
cat > "/root/info.txt" <<END
password user root database: ${db_root_password}
password user bk database: ${bk_password}
END

printf "Server restart in 5 seconds\n"
sleep 5
#reboot
#exit