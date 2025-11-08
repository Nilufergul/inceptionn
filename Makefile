NAME = inception

all: up

up:
	docker-compose -f srcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

build:
	docker-compose -f srcs/docker-compose.yml build

logs:
	docker-compose -f srcs/docker-compose.yml logs -f

ps:
	docker-compose -f srcs/docker-compose.yml ps

clean: down
	docker system prune -af --volumes

fclean: clean
	docker stop $(docker ps -qa) 2>/dev/null || true
	docker rm $(docker ps -qa) 2>/dev/null || true
	docker rmi -f $(docker images -qa) 2>/dev/null || true
	docker volume rm $(docker volume ls -q) 2>/dev/null || true
	docker network rm $(docker network ls -q) 2>/dev/null || true

re: clean all