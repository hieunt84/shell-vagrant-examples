# Script backup for many app on server to google driver
#!/bin/sh

# declare variable
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SERVER_NAME=docker1
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/backup/app1"
# folder need backup app1
APP_DIR="/home/app1"
SCRIPT_BK=/usr/bin/backup-app1.sh
APP_NAME="app1"
SECONDS=0

# Install rclone and config manual
if [ ! -f /usr/sbin/rclone ]; then
    yum -y install wget unzip
    cd /root/
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip rclone-current-linux-amd64.zip
    cp rclone-v*-linux-amd64/rclone /usr/sbin/
    rm -rf rclone-*
fi

# Install and config postfix
if [ ! -f /etc/postfix/sasl_passwd ]; then
    echo "1.Installation postfix and dependencies"
    yum -y install postfix cyrus-sasl-plain mailx
    systemctl start postfix
    systemctl enable postfix
    sudo sleep 1
    echo "1.Installation postfix and dependencies finish"
    
    echo "2.Configure postfix"
    cat >> "/etc/postfix/main.cf" <<EOF
    myhostname = smtp.gmail.com
    relayhost = [smtp.gmail.com]:587
    smtp_use_tls = yes
    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    smtp_sasl_security_options = noanonymous
    smtp_sasl_tls_security_options = noanonymous
EOF
    
    #create file sasl_passwd
    cat > "/etc/postfix/sasl_passwd" <<EOF
    [smtp.gmail.com]:587 infogroup.sup@gmail.com:Infogroup@68
EOF
    # Phân quyền cho file vừa tạo
    postmap /etc/postfix/sasl_passwd
    chown root:postfix /etc/postfix/sasl_passwd*
    chmod 640 /etc/postfix/sasl_passwd*
    systemctl reload postfix
    systemctl restart postfix
fi

# Make folder backup for app1
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Backup
cd "$BACKUP_DIR"
tar -czf backup-$(date +%F\-%H\-%M\-%S).tar.gz "$APP_DIR" >/dev/null 2>&1

# Keep the last 3 backups
# find "$BACKUP_DIR" -type f -name "*.gz" -mtime +3 -delete
find "$BACKUP_DIR" -type f -name "*.gz" -cmin +18 -delete

# cron and email
if [ ! -f /etc/cron.d/app1.cron ]; then
    cat > "/etc/cron.d/app1.cron" <<EOF
    SHELL=/bin/sh
    MAILTO="hieunt9@gmail.com"
    */5 * * * * root $SCRIPT_BK
EOF
    echo "Restarting crond service"
    systemctl restart crond.service
fi

# Backup on Google Drive
echo "Starting Uploading Backup on Google Drive "
rclone copy $BACKUP_DIR "remote:$SERVER_NAME/$TIMESTAMP/$APP_NAME" >> /var/log/rclone.log 2>&1

# Clean up Google Drive
rclone -q --min-age 2w delete "remote:$SERVER_NAME" #Remove all backups older than 2 week
rclone -q --min-age 2w rmdirs "remote:$SERVER_NAME" #Remove all empty folders older than 2 week
rclone cleanup "remote:" >/dev/null 2>&1 #Cleanup Trash
echo "Finished";
echo '';

duration=$SECONDS
echo "Total $size, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."