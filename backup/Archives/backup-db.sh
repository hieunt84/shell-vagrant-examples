#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

rm -rf /home/$server_name/private_html/backup/$dataname
mkdir -p /home/$server_name/private_html/backup/$dataname
cd /home/$server_name/private_html/backup/$dataname

mysqldump -u root -p$mariadb_root_password $dataname | gzip -9 > $dataname.sql.gz
