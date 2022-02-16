#!/bin/bash

#mysql has to be started this way as it doesn't work to call from /etc/init.d
#and files need to be touched to overcome overlay file system issues on Mac and Windows
find /var/lib/mysql -type f -exec touch {} \; && /usr/bin/mysqld_safe & 
sleep 10s

# generate MYSQL information
MYSQL_USER="root"
HACKAZON_DB="hackazon"
HACKAZON_USER="hackazon"

# if mysql password is already set load the existing one
mysql_password_file="/mysql-root-pw.txt"
if grep -sq "." $mysql_password_file
then
    MYSQL_PASSWORD=$(cat $mysql_password_file)
else
    # generate random looking password
    MYSQL_PASSWORD=`date +%s|sha256sum|base64|head -c 10`
    echo $MYSQL_PASSWORD > $mysql_password_file
fi

# generate hackazon information
HACKAZON_PASSWORD=`date +%N|sha256sum|base64|head -c 10`

# if hackazon password is already set load the existing one
hackazon_password_file="/hackazon-db-pw.txt"
if grep -sq "." $hackazon_password_file
then
    HACKAZON_PASSWORD=$(cat $hackazon_password_file)
else
    # generate random looking password
    HACKAZON_PASSWORD=`date +%N|sha256sum|base64|head -c 10`
    echo $HACKAZON_PASSWORD > $hackazon_password_file
fi
HASHED_PASSWORD=`php /passwordHash.php $HACKAZON_PASSWORD`


# log account information
echo
echo ---------- LOGIN INFORMATION ----------
echo mysql: $MYSQL_USER@$MYSQL_PASSWORD
echo hackazon: admin@$HACKAZON_PASSWORD
echo ---------------------------------------
echo

#set DB password in db.php
sed -i "s/yourdbpass/$HACKAZON_PASSWORD/" /var/www/hackazon/assets/config/db.php
sed -i "s/youradminpass/$HACKAZON_PASSWORD/" /var/www/hackazon/assets/config/parameters.php

mysqladmin -u root password $MYSQL_PASSWORD
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $HACKAZON_DB; GRANT ALL PRIVILEGES ON $HACKAZON_DB.* TO '$HACKAZON_USER'@'localhost' IDENTIFIED BY '$HACKAZON_PASSWORD'; FLUSH PRIVILEGES;"
mysql -uroot -p$MYSQL_PASSWORD $HACKAZON_DB < "/var/www/hackazon/database/createdb.sql"
mysql -uroot -p$MYSQL_PASSWORD -e "UPDATE $HACKAZON_DB.tbl_users SET password='${HASHED_PASSWORD}' WHERE username='admin';"

killall mysqld
sleep 10s

supervisord -n
