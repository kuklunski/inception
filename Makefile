all:
	@docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml up -d --build

down:
	@docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down

clean:
	@docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down -v

fclean: clean
	@docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml down --rmi all

re: clean all

.PHONY: all down clean fclean re