# Script install-dependencies for backup solution
#!/bin/sh

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
[smtp.gmail.com]:587 infogroup.sup@gmail.com:password
EOF
# Phân quyền cho file vừa tạo
postmap /etc/postfix/sasl_passwd
chown root:postfix /etc/postfix/sasl_passwd*
chmod 640 /etc/postfix/sasl_passwd*
systemctl reload postfix
systemctl restart postfix
fi

# Install rclone
if [ ! -f /usr/sbin/rclone ]; then
    yum -y install wget unzip
    cd /root/
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
    unzip rclone-current-linux-amd64.zip
    cp rclone-v*-linux-amd64/rclone /usr/sbin/
    rm -rf rclone-*
fi



