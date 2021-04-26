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

########################################################################################
# Install Apache
echo ~~Now Installing Apache~~
yum -y install httpd
systemctl start httpd
systemctl enable httpd
echo ~~Installing Apache Complete~~
echo "------------------------------------"
sleep 1

########################################################################################
# Install php
echo ~~Now Installing PHP~~
yum -y install epel-release yum-utils
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php73
yum -y update

sleep 2
yum -y install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd
yum -y install php-mysql php-pear

systemctl restart httpd
echo ~~Installing PHP Complete~~
echo "------------------------------------"

########################################################################################
# Install WordPress
echo ~~Now Installing WordPress~~
#Install Wordpress
cd /var/www/html
curl -sO https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz

cd /var/www/html/
mv wordpress/* /var/www/html/
mv wp-config-sample.php wp-config.php
sleep 1

#Config Wordpress connect to database server
sed -i 's/database_name_here/db_wp/g' /var/www/html/wp-config.php
sed -i 's/username_here/user_wp/g' /var/www/html/wp-config.php
sed -i 's/password_here/password_wp/g' /var/www/html/wp-config.php
sed -i 's/localhost/172.20.10.200/g' /var/www/html/wp-config.php

echo ~~Now Installing WordPress Complete~~
echo "------------------------------------"

########################################################################################
#Save info
cat > "/root/info.txt" <<END
password user root database: ${db_root_password}
password user bk database: ${bk_password}
password user wp database: ${password_wp}
END

########################################################################################
printf "Server restart in 5 seconds\n"
sleep 5
reboot
#END