FROM debian:bookworm

RUN apt update && apt install -y \
    curl \
    mariadb-client \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-xml \
    php-zip \
    php-imagick \
    php-bcmath \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./configs/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./scripts/install_wordpress.sh /usr/local/bin/install_wordpress.sh

RUN chmod +x /usr/local/bin/install_wordpress.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/install_wordpress.sh"]

CMD ["php-fpm8.2", "-F"]