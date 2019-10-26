mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "RENAME USER '${MYSQL_USER}'@'%' to '${MYSQL_USER}'@'${MYSQL_USER_HOST}';"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "RENAME USER 'root'@'%' to 'root'@'${MYSQL_ROOT_HOST}';"
