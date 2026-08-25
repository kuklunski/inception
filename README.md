*This project has been created as part of the 42 curriculum by Ylemkere.*

# inception

## Description :
Inception is an introduction to system administration, through a project that consists of building a fully containerized web app using Docker and Docker Compose. Each service has to be in its own container, with its own volume, and communicating over a Docker Network.

*Docker :*  
Docker is a platform that packages an application and its dependencies into an isolated environment called a container, it solves the "it works on my machine" problem. It bundles your code, runtime, system tools, and libraries together so your application runs exactly the same way on a laptop, a testing server, or a production server.

*Docker Compose :*  
Since most real-world applications don't run on a single container, Docker Compose is a tool that lets you run and manage multiple interconnected containers at the same time using a single configuration file.
In our case, our web infrastracture needs Nginx, Mariadb and Wordpress all containerized and connected together.
- **NGINX** — the single entrypoint to the infrastructure, exposing port 443 and terminating TLS (TLSv1.2/TLSv1.3 only).
- **WordPress + php-fpm** — the application layer, installed and configured (not served directly — NGINX proxies to it over port 9000).
- **MariaDB** — the database layer, storing WordPress's data.

All containers are built from **Debian (penultimate stable)**.
Two named volumes persist data over restarts:
- 'wordpress_data' stores the wordpress site files.
- 'maria_db' acts as the wordpress database.
Both are stored on the host at `/home/ylemkere/data`. No bind-mounts were allowed.

### Design choices

**Virtual Machines vs Docker :**  
VMs virtualize a full OS including the kernel, which is heavier on resources and slower to start; Docker containers run as isolated processes inside your system's kernel, share the same resources, making them lighter and faster to run. Creating and running 3 VMs instead of 3 Docker containers in this project for example would introduce unnecessary overhead and be highly inefficient.

**Secrets vs Environment Variables :**  
This project uses *Docker secrets* for sensitive data and a .env file for non-sensitive configurations. Standard environment variables are exposed in plain text via docker inspect and process logs, posing a security risk. In contrast, Docker secrets are securely mounted as in-memory files inside the container, ensuring critical credentials are isolated and never written to disk.

**Docker Network vs Host Network :**  
This project uses a Docker bridge network for the containers; network: host, is forbidden by the subject. Using host networking removes the isolation between the container and the host system, exposing all internal ports and defeating the core security benefits of containerization. A Docker bridge creates a private, virtual network inside your computer. Containers can easily talk to each other using their container names, but they are completely isolated from the outside world unless you explicitly expose a port.

**Docker Volumes vs Bind Mounts :**  
We use named volumes for WordPress and MariaDB data, Bind mounts are forbidden in this project.
- Named Volumes: Docker creates and completely manages a dedicated folder inside its own internal storage. It isolates your data from the rest of your machine, handles permissions automatically, and keeps your files safe even if you delete the container.
- Bind Mounts: You point Docker directly to an exact folder on your host machine's hard drive (e.g., /home/user/my-project/data). The container reads and writes to that specific local folder in real time, making it highly dependent on your personal computer's file structure and permissions.

### Prerequisites
- A Virtual Machine running Linux
- Docker and Docker Compose installed
This builds all Docker images via `docker-compose.yml` and starts the containers.

Other useful targets:
```bash
make down     # Stop and remove containers and networks
make clean    # Stop containers and safely remove specific build artifacts
make fclean   # Full clean: down containers, delete named volumes, and wipe all persistent data
make re       # Rebuild everything from scratch (fclean followed by make)
```
## Resources
- [Mainly Youtube.com and the services documentation pages]
- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress CLI (wp-cli) documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)

### AI usage
AI (Claude) was used for:
- Helped structuring this README.md and the two documentation files (USER_DOC.md, DEV_DOC.md) into the sections required by the subject.
- Explaining the reasoning behind the technical comparisons (VM vs Docker, Secrets vs Environment Variables, Docker Network vs Host Network, Docker Volumes vs Bind Mounts) — the explanations were then written and understood by me, not copy-pasted.

All Dockerfiles, docker-compose.yml, entrypoint scripts, and WordPress/MariaDB/NGINX configuration were written and debugged independently.