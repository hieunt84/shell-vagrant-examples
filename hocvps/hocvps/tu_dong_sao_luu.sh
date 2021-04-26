#!/bin/sh

. /etc/hocvps/scripts.conf

printf "=========================================================================\n"
printf "                          Tu Dong Sao Luu Data\n"
printf "=========================================================================\n"
printf "Vui long doc ky huong dan tai hocvps.com truoc khi dung tinh nang nay\n\n"
echo -n "Nhap vao ten data ban muon tu dong sao luu roi an [ENTER]: "
read dataname
if [ -f /bin/stbackupdb-$dataname ]; then
echo "Data $dataname da duoc tu dong sao luu truoc roi!"
echo "Chao tam biet....!"
exit
fi

if [ -f /var/lib/mysql/$dataname/db.opt ]; then

echo -n "Ban muon script tu dong backup data nay luc may gio ?[0-23]: "
read gio

if [ "$gio" = "" ]; then
        gio="3"
echo "Ban khong nhap gio, lay mac dinh la 3h sang"
fi

echo -n "Ban muon script tu dong backup data nay vao thu may ?[0-7]: "
read thu

if [ "$thu" = "" ]; then
        thu="0"
echo "Ban khong nhap thu, lay mac dinh la chu nhat"
fi

if [ "$thu" = "0" ] || [ "$thu" = "7" ]; then
        thu12="chu nhat"
fi
if [ "$thu" = "1" ]; then
        thu12="thu 2"
fi
if [ "$thu" = "2" ]; then
        thu12="thu 3"
fi
if [ "$thu" = "3" ]; then
        thu12="thu 4"
fi
if [ "$thu" = "4" ]; then
        thu12="thu 5"
fi
if [ "$thu" = "5" ]; then
        thu12="thu 6"
fi
if [ "$thu" = "6" ]; then
        thu12="thu 7"
fi


read -r -p "Ban co chac muon tu dong sao luu $dataname luc $gio gio $thu12 hang tuan ? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
cat > "/bin/stbackupdb-$dataname" <<END
#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

rm -rf /home/$server_name/private_html/backup/$dataname
mkdir -p /home/$server_name/private_html/backup/$dataname
cd /home/$server_name/private_html/backup/$dataname

mysqldump -u root -p$mariadb_root_password $dataname | gzip -9 > $dataname.sql.gz
END

chmod +x /bin/stbackupdb-$dataname


cat >> "/etc/cron.d/db.cron" <<END
SHELL=/bin/sh
0 $gio * * $thu root /bin/stbackupdb-$dataname >/dev/null 2>&1
END
systemctl restart  crond.service

echo "Data $dataname se duoc tu dong sao luu vao $gio gio $thu12 hang tuan. Ban se nhan duoc email thong bao khi hoan tat."
        ;;
    *)
        echo "Chao tam biet....!"
        ;;
esac
else
echo "Khong tim thay data $dataname trong server!"
echo "Chao tam biet...!"
exit
fi
