#!/bin/sh

if [ -f /var/www/html/wp-config.php ]
then
	echo "WordPress already configured"
else

    echo "Downloading WordPress"

    curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    cp -a /tmp/wordpress/. /var/www/html/

    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sed -i "s/username_here/$MYSQL_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$MYSQL_HOSTNAME/" /var/www/html/wp-config.php
    sed -i "s/database_name_here/$MYSQL_DATABASE/" /var/www/html/wp-config.php

    echo "WordPress configured"
fi

exec php-fpm8.2 -F