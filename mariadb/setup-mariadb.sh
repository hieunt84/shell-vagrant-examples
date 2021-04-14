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

mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
echo ~~II.Configure mysql_secure_installation_automatically Complete~~
echo "------------------------------------"

# III.Configuring Backup Automatically
echo ~~III.Now Configuring Backup.~~
# 1.Create user backup.
sleep 1
echo ~~1.Create user backup.~~
#Variables
bk_user="bk"
bk_password=`date |md5sum |cut -c '14-30'`
mysql --user=root --password=${db_root_password}<<_EOF_
  CREATE USER $bk_user@'localhost' IDENTIFIED BY '$bk_password';
  GRANT ALL ON *.* TO '$bk_user'@'localhost';
_EOF_
echo ~~1.Creat user backup Complete.~~
echo "------------------------------------"

# 2.Config my.cnf.
echo ~~2.Config my.cnf~~

sudo echo "[client]" >> /etc/my.cnf
sudo echo "user = ${bk_user}" >> /etc/my.cnf
sudo echo "password = ${bk_password}" >> /etc/my.cnf
sudo chmod 600 /etc/my.cnf

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
[smtp.gmail.com]:587 infogroup.sup@gmail.com:password
END
postmap /etc/postfix/sasl_passwd
chown root:postfix /etc/postfix/sasl_passwd*
chmod 640 /etc/postfix/sasl_passwd*
systemctl reload postfix
systemctl restart postfix
echo "Configure postfix finish"
echo "~~IV.Configuring send email with postfix Complete~~"
echo "------------------------------------"

# Create database WordPress
echo ~~Creat database wordpress~~
# Variables
db_wp="db_wp"
user_wp="user_wp"
password_wp="password_wp"
web_host="172.20.10.%"

mysql --user=root --password=${db_root_password}<<END
  CREATE DATABASE $db_wp;
  CREATE USER '$user_wp'@'$web_host' IDENTIFIED BY '$password_wp';
  GRANT ALL ON $db_wp.* TO '$user_wp'@'$web_host';
END

#Save info
cat > "/root/info.txt" <<END
password user root database: ${db_root_password}
password user bk database: ${bk_password}
END

printf "Server restart in 5 seconds\n"
sleep 5
#reboot
#exit