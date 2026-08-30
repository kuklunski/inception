# Developer Documentation

## 1. Project Structure

The repository is organized as follows:

```text
inception/
├── DEV_DOC.md
├── README.md
├── USER_DOC.md
├── html/
└── srcs/
    ├── docker-compose.yml
    ├── requirements/
    │   ├── mariadb/
    │   ├── nginx/
    │   └── wordpress/
    └── secrets/
```

The `srcs` directory contains the Docker Compose configuration, service configurations, Dockerfiles, scripts and secrets.

## 2. Prerequisites

The development environment requires:

* Docker
* Docker Compose
* GNU Make
* Git
* A Linux environment or a compatible virtualized environment such as WSL2

Verify Docker:

```bash
docker --version
```

Verify Docker Compose:

```bash
docker compose version
```

Verify Make:

```bash
make --version
```

## 3. Configuration

The Docker Compose configuration is located at:

```text
srcs/docker-compose.yml
```

The project defines three services:

* `nginx`
* `wordpress`
* `mariadb`

The services communicate through the Docker network defined by Docker Compose.

### NGINX

The NGINX configuration is located in:

```text
srcs/requirements/nginx/
```

NGINX provides the HTTPS entry point and forwards PHP requests to the WordPress container.

### WordPress

The WordPress configuration, PHP-FPM configuration and installation scripts are located in:

```text
srcs/requirements/wordpress/
```

The WordPress container uses PHP-FPM to execute PHP code.

### MariaDB

The MariaDB configuration and initialization script are located in:

```text
srcs/requirements/mariadb/
```

MariaDB listens on port `3306` inside the Docker network.

## 4. Secrets

Sensitive credentials are stored as Docker secrets.

You will have to create 3 files for secrets since it is forbidden to push any credentials, API keys,
or passwords into git.
the files are as follows :
- db_password.txt
- db_root_password.txt
- wp_admin_password.txt

Use this command :
```bash
mkdir -p srcs/secrets && \
echo -n "database1234" > srcs/secrets/db_password.txt && \
echo -n "root1234" > srcs/secrets/db_root_password.txt && \
echo -n "wordpress1234" > srcs/secrets/wp_admin_password.txt
```

The secrets are located in:

```text
srcs/secrets/
```

The MariaDB service uses secrets for credentials such as:

* MariaDB root password
* WordPress database user password

Secrets should never be hard-coded into Dockerfiles, source code or committed to public repositories.

## 5. Building the Project

From the repository root:

```bash
cd /inception
```

Build the project using the Makefile:

```bash
make
```

The Makefile is responsible for invoking the Docker Compose configuration.

The project can also be built directly:

```bash
cd srcs
docker compose build
```

To force a complete rebuild without using the Docker build cache:

```bash
docker compose build --no-cache
```

## 6. Launching the Project

From `srcs`:

```bash
docker compose up
```

To launch the stack in detached mode:

```bash
docker compose up -d
```

To rebuild and launch:

```bash
docker compose up --build
```

## 7. Managing Containers

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Check the Compose services:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Follow logs:

```bash
docker compose logs -f
```

View logs for a specific service:

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
```

Open a shell inside a running container:

```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

Stop the project:

```bash
docker compose down
```

Restart the project:

```bash
docker compose restart
```

## 8. Managing Images

List images:

```bash
docker images
```

Rebuild a specific service:

```bash
docker compose build mariadb
docker compose build wordpress
docker compose build nginx
```

Rebuild a service without cache:

```bash
docker compose build --no-cache mariadb
```

## 9. Managing Volumes

The project uses Docker named volumes for persistent data.

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

The MariaDB volume is mounted inside the container at:

```text
/var/lib/mysql
```

The WordPress volume is mounted inside the container at:

```text
/var/www/html
```

These volumes ensure that container recreation does not automatically delete the database or WordPress files.

### Removing Volumes

To remove the Compose containers, network and volumes:

```bash
docker compose down -v
```

This is destructive because the persistent project data stored in the volumes will be deleted.

After removing the volumes, MariaDB starts with a new empty data directory and its initialization script creates the database and database user again.

## 10. Data Persistence

Persistent project data is stored through Docker named volumes rather than inside the containers.

The two important volumes are:

```text
srcs_mariadb_data
srcs_wordpress_data
```

MariaDB data persists in:

```text
/var/lib/mysql
```

inside the MariaDB container.

WordPress files persist in:

```text
/var/www/html
```

inside the WordPress container.

The containers themselves are disposable. Removing and recreating a container does not remove its named volume.

## 11. Complete Reset

When testing the initialization process from a completely clean state:

```bash
cd ~/inception/srcs
docker compose down -v
docker compose build --no-cache
docker compose up
```

This removes the existing containers and persistent volumes, rebuilds the images, creates new volumes and starts the complete stack.

This should only be used when existing database and WordPress data can be discarded.

## 12. Debugging

Check whether all services are running:

```bash
docker compose ps
```

Check the MariaDB logs:

```bash
docker compose logs mariadb
```

MariaDB should eventually report:

```text
mysqld: ready for connections.
```

Check the WordPress logs:

```bash
docker compose logs wordpress
```

Check the NGINX logs:

```bash
docker compose logs nginx
```

Check that the containers share the expected network:

```bash
docker network ls
docker network inspect srcs_inception-network
```

Check the MariaDB users:

```bash
docker exec -it mariadb mariadb -u root -p
```

Then:

```sql
SELECT User, Host FROM mysql.user;
```

Check the WordPress database:

```sql
SHOW DATABASES;
```

The WordPress database user should have privileges on the WordPress database.

## 13. Development Workflow

After modifying a Dockerfile:

```bash
docker compose build <service>
docker compose up <service>
```

After modifying a service configuration or script copied into an image, rebuild that service:

```bash
docker compose build <service>
docker compose up
```

For example:

```bash
docker compose build mariadb
docker compose up mariadb
```

When changes affect multiple services:

```bash
docker compose up --build
```

For a completely clean test of initialization:

```bash
docker compose down -v
docker compose up --build
```
