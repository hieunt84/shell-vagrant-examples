#!/bin/bash

echo "Updating system"
sudo yum -y update
sudo sleep 5

echo "Setting timezone"
sudo timedatectl set-timezone Asia/Ho_Chi_Minh

echo "Disable firewall"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Installation postfix and dependencies"
sudo yum -y install postfix cyrus-sasl-plain mailx
sudo sleep 2

echo "Start postfix"
sudo systemctl start postfix
sudo systemctl enable postfix
sudo sleep 1

echo "Configure postfix"
sudo -i
sleep 1
sudo echo "myhostname = smtp.gmail.com" >> /etc/postfix/main.cf
sudo echo "relayhost = [smtp.gmail.com]:587" >> /etc/postfix/main.cf
sudo echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
sudo echo "smtp_sasl_tls_security_options = noanonymous" >> /etc/postfix/main.cf

#create file sasl_passwd
sudo echo "[smtp.gmail.com]:587 infogroup.sup@gmail.com:password" >> /etc/postfix/sasl_passwd

sudo postmap /etc/postfix/sasl_passwd
sudo chown root:postfix /etc/postfix/sasl_passwd*
sudo chmod 640 /etc/postfix/sasl_passwd*
sudo systemctl reload postfix
sudo systemctl restart postfix
echo "Configure postfix finish"