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