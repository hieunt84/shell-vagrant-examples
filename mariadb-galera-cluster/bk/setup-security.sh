# II.Config Secure mysql_secure_installation_automatically
# ref http://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
echo ~~II.Now Config mysql_secure_installation_automatically~~
# Variables
db_root_password=`date |md5sum |cut -c '14-30'`

mysql --user=root <<_EOF_
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
echo ~~II.Configure mysql_secure_installation_automatically Complete~~
echo "------------------------------------"

