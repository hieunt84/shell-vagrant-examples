### Ref
- https://hocvps.com/tong-quat-ve-crontab/
- https://linuxize.com/post/scheduling-cron-jobs-with-crontab/

### commands
$crontab -e
  MAILTO="infogroup.sup@gmail.com"
  0 0 * * * sh /home/hieunt/backup.sh

#### check
$crontab -l

### location file crontab
- /var/spool/cron/username