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
hostnamectl set-hostname node2

# config file host
cat >> "/etc/hosts" <<END
172.20.10.199 node1
172.20.10.200 node2
172.20.10.201 node3
172.20.10.198 controlpanel
END

# config network

##########################################################################################
# SECTION 2: INSTALL MARIADB 10.4 AND DEPENDENCIES

#install mariadb
echo ~~Now Installing MariaDB~~
cat > "/etc/yum.repos.d/mariadb.repo" <<END
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
END

yum makecache --disablerepo='*' --enablerepo='mariadb'
yum -y install MariaDB-server MariaDB-client


systemctl start mariadb
systemctl enable mariadb
echo ~~Installing MariaDB Complete~~
echo "------------------------------------"

#Install galera and rsync
yum -y install galera rsync policycoreutils-python
sleep 1

#########################################################################################
# SECTION 3: CONFIG CLUSTERING GALERA 3 NODE

# Config clustering
cat > "/etc/my.cnf.d/galera.cnf" <<END
[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0

[galera]
# Galera Provider Configuration
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so

# Galera Cluster Configuration
wsrep_cluster_name="test_cluster"
wsrep_cluster_address="gcomm://172.20.10.199,172.20.10.200,172.20.10.201"

# Galera Synchronization Configuration
wsrep_sst_method=rsync

# Galera Node Configuration
wsrep_node_address="172.20.10.200"
wsrep_node_name="node2"
END

#stop mariadb to start cluster
systemctl stop mariadb

#########################################################################################
# SECTION 4: FINISHED
printf "Server restart in 5 seconds\n"
sleep 5
reboot