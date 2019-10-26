mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "RENAME USER '${MYSQL_USER}'@'%' to '${MYSQL_USER}'@'${MYSQL_USER_HOST}';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "UPDATE mysql.user set host = '${MYSQL_ROOT_HOST}' where user = 'root' AND host = '%';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH privileges;"
