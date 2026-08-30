#!/bin/sh

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

if ! wp core is-installed --allow-root
then
    echo "Installing WordPress..."

    if [ ! -f /var/www/html/wp-config.php ]; then

        echo "Downloading WordPress"

        curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
        tar -xzf /tmp/wordpress.tar.gz -C /tmp
        cp -a /tmp/wordpress/. /var/www/html/

        cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

        sed -i "s/username_here/$MYSQL_USER/" /var/www/html/wp-config.php
        sed -i "s/password_here/$MYSQL_PASSWORD/" /var/www/html/wp-config.php
        sed -i "s/localhost/$MYSQL_HOSTNAME/" /var/www/html/wp-config.php
        sed -i "s/database_name_here/$MYSQL_DATABASE/" /var/www/html/wp-config.php
    fi

    echo "Waiting for MariaDB..."

    until mysqladmin ping \
        -h"$MYSQL_HOSTNAME" \
        -u"$MYSQL_USER" \
        -p"$MYSQL_PASSWORD" \
        --silent
    do
        sleep 2
    done

    echo "MariaDB is ready"

    wp core install \
        --url="https://ylemkere.42.fr" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "WordPress installed"
else
    echo "WordPress already installed"
fi

exec php-fpm8.2 -F