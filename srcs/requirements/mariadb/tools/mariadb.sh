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

    cat > /tmp/init.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';

CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';

GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;

SELECT 'initialized' INTO OUTFILE '/var/lib/mysql/.initialized';
EOF

    chown mysql:mysql /tmp/init.sql
    chmod 600 /tmp/init.sql

    exec mysqld --user=mysql --console --init-file=/tmp/init.sql
fi

exec mysqld --user=mysql --console
