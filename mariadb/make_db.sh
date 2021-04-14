# Make database and tables.
# https://stackoverflow.com/questions/41645309/mysql-error-access-denied-for-user-rootlocalhost
# ref https://stackoverflow.com/questions/2428416/how-to-create-a-database-from-shell-command

DB="example_database"
USER="example_user"
PASS="password"
TABLE="todo_list"
db_root_password="VMware1!"

mysql --user=root --password=$db_root_password << EOF 
  CREATE DATABASE $DB CHARACTER SET utf8 COLLATE utf8_general_ci;
  CREATE USER $USER@'localhost' IDENTIFIED BY '$PASS';
  GRANT SELECT, INSERT, UPDATE ON $DB.* TO '$USER'@'localhost';
  CREATE TABLE example_database.$TABLE (
    item_id INT AUTO_INCREMENT,
    content VARCHAR(255),
    PRIMARY KEY(item_id)
  );
EOF

# insert data in database example_database
# https://stackoverflow.com/questions/39215064/insert-into-mysql-from-bash-script

mysql --user=$USER --password=$PASS $DB << EOF
INSERT INTO $TABLE (\`content\`) VALUES ("My first important item");
EOF