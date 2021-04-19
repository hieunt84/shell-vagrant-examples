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

##################################################################################
# Install nginx
echo ~~Now Installing nginx~~
yum -y install epel-release
yum -y update
yum -y install nginx
systemctl start nginx
systemctl enable nginx
echo ~~Installing nginx Complete~~
echo "------------------------------------"
sleep 1
##################################################################################
# Config nginx
cat >> "/etc/nginx/conf.d/example.com.conf" << END
server {
   listen 80;
   server_name example.com;
   access_log off;
   error_log off;

   location / {
      client_max_body_size 10m;
      client_body_buffer_size 128k;
 
      proxy_send_timeout 90;
      proxy_read_timeout 90;
      proxy_buffer_size 128k;
      proxy_buffers 4 256k;
      proxy_busy_buffers_size 256k;
      proxy_temp_file_write_size 256k;
      proxy_connect_timeout 30s;
 
      proxy_redirect http://www.example.com:8080 http://www.example.com;
      proxy_redirect http://example.com:8080 http://example.com;
 
      proxy_pass http://127.0.0.1:8080/;
 
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   }

   # Select files to be deserved by nginx
   location ~* ^.+\.(jpg|jpeg|gif|css|png|js|ico|txt|srt|swf|zip|rar|html|htm|pdf)$ {
      root /var/www/html;
      expires 30d; # caching, expire after 30 days
   }
}

END
#check nginx
#ref https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/
curl -I 127.0.0.1