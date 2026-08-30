# User Documentation

## 1. Overview

This project provides a small web stack composed of three services running in Docker containers:

* **NGINX** — the web server and HTTPS entry point.
* **WordPress** — the website and its PHP-FPM application.
* **MariaDB** — the database used by WordPress.

The services communicate through a Docker network. NGINX receives HTTPS requests and forwards PHP requests to WordPress. WordPress communicates with MariaDB to store website data.

## 2. Starting the Project

Go to the project directory:

```bash
cd /inception
```

You will have to create 3 files for secrets since it is forbidden to push any credentials, API keys,
or passwords into git.
the files are as follows :
- /srcs/secrets/db_password.txt
- /srcs/secrets/db_root_password.txt
- /srcs/secrets/wp_admin_password.txt

Use this command at the root of the repo :
```bash
mkdir -p srcs/secrets && \
echo -n "database1234" > srcs/secrets/db_password.txt && \
echo -n "root1234" > srcs/secrets/db_root_password.txt && \
echo -n "wordpress1234" > srcs/secrets/wp_admin_password.txt
```
```

Start the project using the Makefile:

```bash
make
```

Alternatively, from the `srcs` directory:

```bash
cd srcs
docker compose up
```

To start the containers in the background:

```bash
docker compose up -d
```

## 3. Stopping the Project

To stop the containers:

```bash
cd /inception/srcs
docker compose down
```

This stops and removes the containers and network but does not remove the persistent volumes.

To stop the project and remove its volumes:

```bash
docker compose down -v
```

**Warning:** Removing the volumes deletes the persistent MariaDB database and WordPress files stored in those volumes.

## 4. Accessing the Website

The website is available through HTTPS using the configured domain:

```text
https://ylemkere.42.fr
```

The project uses a self-signed TLS certificate, so the browser may display a security warning. This is expected.

The domain must resolve to the machine running the Docker stack. For local use, the `/etc/hosts` file can be configured to point the domain to `127.0.0.1`.

## 5. Accessing the WordPress Administration Panel

The WordPress administration panel is available at:

```text
https://ylemkere.42.fr/wp-admin
```

Use the WordPress administrator credentials configured during installation.

## 6. Credentials

Database credentials are stored as Docker secrets and are not stored directly in the Dockerfiles.

The project stores secrets in:

```text
srcs/secrets/
```

The secrets include the MariaDB root password and the WordPress database user's password.

The WordPress administrator credentials are configured separately by the WordPress installation script.

Do not commit real passwords or other sensitive credentials to Git.

## 7. Checking the Services

Check the status of the containers:

```bash
docker compose ps
```

All three services should be running:

```text
mariadb
wordpress
nginx
```

To view the logs:

```bash
docker compose logs
```

To follow the logs in real time:

```bash
docker compose logs -f
```

To inspect one service:

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
```

MariaDB should report that it is ready for connections.

WordPress should complete its installation.

NGINX should remain running and listen for HTTPS connections.

## 8. Checking the Database

A MariaDB shell can be opened with:

```bash
docker exec -it mariadb mariadb -u root -p
```

Enter the MariaDB root password when prompted.

Inside MariaDB, databases can be listed with:

```sql
SHOW DATABASES;
```

Database users can be checked with:

```sql
SELECT User, Host FROM mysql.user;
```

## 9. Checking the Volumes

List Docker volumes:

```bash
docker volume ls
```

The project uses persistent volumes for:

* MariaDB data
* WordPress data

These volumes allow the database and website files to survive container recreation.

To inspect the volumes:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

Do not remove these volumes unless you intentionally want to delete the stored project data.
