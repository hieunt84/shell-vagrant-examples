# HocVPS Script Plugin - Backup Server and Upload to Cloud

#!/bin/bash

SERVER_NAME=HOCVPS_BACKUP

TIMESTAMP=$(date +"%F")
BACKUP_DIR="/root/backup/$TIMESTAMP"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
SECONDS=0

mkdir -p "$BACKUP_DIR/mysql"

echo "Starting Backup Database";
databases=`$MYSQL -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)"`

for db in $databases; do
	$MYSQLDUMP --force --opt $db | gzip > "$BACKUP_DIR/mysql/$db.gz"
done
echo "Finished";
echo '';

echo "Starting Backup Website";
# Loop through /home directory
for D in /home/*; do
	if [ -d "${D}" ]; then #If a directory
		domain=${D##*/} # Domain name
		echo "- "$domain;
		zip -r $BACKUP_DIR/$domain.zip /home/$domain/public_html/ -q -x /home/$domain/public_html/wp-content/cache/**\* #Exclude cache
	fi
done
echo "Finished";
echo '';

echo "Starting Backup Nginx Configuration";
cp -r /etc/nginx/conf.d/ $BACKUP_DIR/nginx/
echo "Finished";
echo '';

size=$(du -sh $BACKUP_DIR | awk '{ print $1}')

echo "Starting Uploading Backup";
/usr/sbin/rclone move $BACKUP_DIR "remote:$SERVER_NAME/$TIMESTAMP" >> /var/log/rclone.log 2>&1
# Clean up
rm -rf $BACKUP_DIR
/usr/sbin/rclone -q --min-age 2w delete "remote:$SERVER_NAME" #Remove all backups older than 2 week
/usr/sbin/rclone -q --min-age 2w rmdirs "remote:$SERVER_NAME" #Remove all empty folders older than 2 week
/usr/sbin/rclone cleanup "remote:" #Cleanup Trash
echo "Finished";
echo '';

duration=$SECONDS
echo "Total $size, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."