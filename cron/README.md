# https://hocvps.com/tong-quat-ve-crontab/
# https://linuxize.com/post/scheduling-cron-jobs-with-crontab/

$crontab -e
  MAILTO="infogroup.sup@gmail.com"
  0 0 * * * sh /home/hieunt/backup.sh

$crontab -l # check
# location file crontab
  /var/spool/cront/username