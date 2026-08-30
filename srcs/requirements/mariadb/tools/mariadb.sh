#!/bin/sh
set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -f "/var/lib/mysql/.initialized" ]; then

    echo "Initializing MariaDB..."

    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
    fi

    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    tmp_pid="$!"

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql --socket=/run/mysqld/mysqld.sock -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"$DB_ROOT_PASSWORD" shutdown
    wait "$tmp_pid"

    touch /var/lib/mysql/.initialized

    echo "MariaDB initialized"

fi

exec mysqld --user=mysql --console