#!/bin/bash
# BEGIN
# Pretask
echo ~~Configuring Pretask~~
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
echo ~~Configuring Pretask Complete~~


#########################################################################################
# Install MariaDB
echo ~~Now Installing MariaDB -Attended Installation~~
yum -y install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb.service
echo ~~MariaDB Installation Complete~~
echo "------------------------------------"
sleep 1

# Config Secure mysql_secure_installation_automatically
# ref http://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
echo ~~Now Config mysql_secure_installation_automatically~~
# Variables
db_root_password=`date |md5sum |cut -c '14-30'`

mysql --user=root <<END
  UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
END
echo ~~Configure mysql_secure_installation_automatically Complete~~
echo "------------------------------------"

# Create database WordPress
echo ~~Creat database wordpress~~
# Variables
db_wp="db_wp"
user_wp="user_wp"
password_wp="password_wp"
web_host="172.20.10.201"

mysql --user=root --password=${db_root_password}<<END
  CREATE DATABASE $db_wp;
  CREATE USER '$user_wp'@'$web_host' IDENTIFIED BY '$password_wp';
  GRANT ALL ON $db_wp.* TO '$user_wp'@'$web_host';
END


##########################################################################################
#Save info
cat > "/root/info.txt" <<END
password user root database: ${db_root_password}
password user wp database: ${password_wp}
END
printf "Server restart in 5 seconds\n"
sleep 5
reboot
#END