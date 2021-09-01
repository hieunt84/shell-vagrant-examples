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
echo ~~Configuring Pretask Complete~~

######################################################################################

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

# Check php
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

#########################################################################################
# I.Install MariaDB
echo ~~I.Now Installing MariaDB -Attended Installation~~
yum -y install mariadb-server mariadb
systemctl start mariadb
systemctl enable mariadb.service
echo ~~I.MariaDB Installation Complete~~
echo "------------------------------------"
sleep 1

# II.Config Secure mysql_secure_installation_automatically
# ref http://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
echo ~~II.Now Config mysql_secure_installation_automatically~~
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
echo ~~II.Configure mysql_secure_installation_automatically Complete~~
echo "------------------------------------"

##################################################################################################
# III.Configuring Backup Database Automatically
echo ~~III.Now Configuring Backup.~~
# 1.Create user backup.
sleep 1
echo ~~1.Create user backup.~~
#Variables
bk_user="bk"
bk_password=`date |md5sum |cut -c '14-30'`
mysql --user=root --password=${db_root_password}<<END
  CREATE USER $bk_user@'localhost' IDENTIFIED BY '$bk_password';
  GRANT ALL ON *.* TO '$bk_user'@'localhost';
END
echo ~~1.Creat user backup Complete.~~
echo "------------------------------------"

# 2.Config my.cnf.
echo ~~2.Config my.cnf~~
cat > "/etc/my.cnf.d/backup.cnf" <<END
[client]
user = ${bk_user}
password = ${bk_password}
END

chmod 600 /etc/my.cnf.d/backup.cnf

echo ~~2.Config my.cnf Complete.~~
echo "------------------------------------"

# 3.Create a directory to store the backups.
echo ~~3.Create a directory to store the backups.~~
sudo mkdir -p /root/db_backups
echo ~~3.Create a directory to store the backups Complete.~~
echo "------------------------------------"
  
# 4. Make crontab
echo ~~4.Make crontab.~~
cat > "/bin/stbackupdb" <<END
#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/binls
mysqldump --all-databases | gzip -9 > /root/db_backups/db-all-$(date +\%Y\%m\%d).sql.gz
END
sudo chmod 755 /bin/stbackupdb
cat >> "/etc/cron.d/db.cron" <<END
SHELL=/bin/sh
MAILTO="infogroup.sup@gmail.com"
0 3 * * * root /bin/stbackupdb >/dev/null 2>&1
0 5 * * * root find /root/db_backups -type f -name "*.gz" -mtime +14 -delete
END
systemctl restart crond
echo ~~4.Make crontab Complete.~~
echo "------------------------------------"

echo ~~III.Configuring Backup Complete~~
echo "------------------------------------"

##################################################################################################
# IV.Configuring send email with postfix
echo "~~IV.Configuring send email with postfix~~"
echo "1.Installation postfix and dependencies"
yum -y install postfix cyrus-sasl-plain mailx
systemctl start postfix
systemctl enable postfix
sudo sleep 1

echo "2.Configure postfix"
cat >> "/etc/postfix/main.cf" <<END
myhostname = smtp.gmail.com
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
END

#create file sasl_passwd
cat > "/etc/postfix/sasl_passwd" <<END
[smtp.gmail.com]:587 infogroup.sup@gmail.com:Infogroup@68
END
postmap /etc/postfix/sasl_passwd
chown root:postfix /etc/postfix/sasl_passwd*
chmod 640 /etc/postfix/sasl_passwd*
systemctl reload postfix
systemctl restart postfix
echo "Configure postfix finish"
echo "~~IV.Configuring send email with postfix Complete~~"
echo "------------------------------------"

##################################################################################################
# V.Install webmin
echo ~~Now Installing Webmin~~
cat > "/etc/yum.repos.d/webmin.repo" <<END
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
END
wget http://www.webmin.com/jcameron-key.asc
rpm --import jcameron-key.asc
yum -y install webmin
echo ~~Now Installing Webmin Complete~~
echo "------------------------------------"

##################################################################################################
# VI. Install WordPress
echo ~~Now Installing WordPress~~
# Create database WordPress
# Variables
db_wp="db_wp"
user_wp="user_wp"
password_wp="password_wp"
web_host="localhost"
mysql --user=root --password=${db_root_password}<<END
  CREATE DATABASE $db_wp;
  CREATE USER '$user_wp'@'$web_host' IDENTIFIED BY '$password_wp';
  GRANT ALL ON $db_wp.* TO '$user_wp'@'$web_host';
END

#Install Wordpress
cd /var/www/html
curl -sO https://wordpress.org/latest.tar.gz
tar xzf latest.tar.gz

cd /var/www/html/
mv wordpress/* /var/www/html/
mv wp-config-sample.php wp-config.php
sleep 1

#Config Wordpress connect to database on localhost
sed -i 's/database_name_here/db_wp/g' /var/www/html/wp-config.php
sed -i 's/username_here/user_wp/g' /var/www/html/wp-config.php
sed -i 's/password_here/password_wp/g' /var/www/html/wp-config.php

echo ~~Now Installing WordPress~~
echo "------------------------------------"

##################################################################################################
# VII.Save info
cat > "/root/info.txt" <<END
password user root database: ${db_root_password}
password user bk database: ${bk_password}
password user wp database: ${password_wp}
END
printf "Server restart in 5 seconds\n"
sleep 5
reboot
