#!/bin/bash

# Install
sudo -i
yum -y install cronie

# enable
systemctl enable crond

# prepare backup
# make directory backups
mkdir -p /root/backups

# make script backup.sh

cat > "/bin/stbackupdb" <<END
#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/binls

# backup database mysql
mysqldump --all-databases | gzip -9 > /root/backups/db-all-$(date +\%Y\%m\%d).sql.gz

# backup directory public_html (souce code web)
tar -czvf /root/backups/backup_domain.com_$(date +"%Y-%m-%d").tar.gzip /home/domain.com/public_html

END

# permission
sudo chmod 755 /bin/stbackupdb

# Make crontab
cat >> "/etc/cron.d/backup.cron" <<END
SHELL=/bin/sh
MAILTO="infogroup.sup@gmail.com"
0 3 * * * root /bin/stbackupdb >/dev/null 2>&1
0 5 * * * root find /root/backups -type f -name "*.gz" -mtime +14 -delete
END

# restart crond
systemctl restart crond