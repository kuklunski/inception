all:
	docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down

clean:
	docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down -v

stop:
	@docker compose -f ./srcs/docker-compose.yml stop

start:
	@docker compose -f ./srcs/docker-compose.yml start

fclean: clean
	docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down --rmi all
	sudo rm -rf /home/ylemkere/data/wordpress/*
	sudo rm -rf /home/ylemkere/data/mariadb/*

re: fclean all

.PHONY: all down stop start clean fclean re