FROM debian:bookworm

RUN apt update && apt install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/mariadb.sh /usr/local/bin/mariadb.sh
COPY ./configs/my.cnf /etc/mysql/my.cnf

RUN chmod +x /usr/local/bin/mariadb.sh

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]