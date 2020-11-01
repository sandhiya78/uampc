#!/bin/bash

# mysql
MYSQL_DATA_DIR=/var/lib/mysql
if [ -z "$(ls -A ${MYSQL_DATA_DIR})" ]; then
    # mysql db is not exists, initialize it
    mysqld --initialize-insecure --user=mysql
    SOCKET="$(mysqld --verbose --help | awk -v conf='socket' '$1 == conf && /^[^ \t]/ { sub(/^[^ \t]+[ \t]+/, ""); print; exit }')"
    mysqld --daemonize --skip-networking --socket="${SOCKET}" --user=mysql
    mysql -uroot --protocol=socket --socket="${SOCKET}" <<<"ALTER USER USER() IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';UPDATE mysql.user SET Host='%' WHERE User='root' AND Host='localhost';"
    mysqladmin shutdown --socket="${SOCKET}" -uroot -p${MYSQL_ROOT_PASSWORD}
fi
chown -R mysql:mysql ${MYSQL_DATA_DIR}
chmod 750 ${MYSQL_DATA_DIR}
mysqld_safe --timezone=${TZ}&

# postfix
postfix start

# apache
ln -sf /dev/stdout /var/log/apache2/access.log
ln -sf /dev/stderr /var/log/apache2/error.log
sed -i "s~\;date.timezone =~date.timezone = ${TZ}~g" /etc/php/7.4/apache2/php.ini
chown -R www-data:www-data /var/www
find /etc/apache2/sites-available/ -type f -and -not -name "*default*" -exec a2ensite {} \;
apachectl -DFOREGROUND -k start
