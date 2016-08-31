# keeping for docker commands

all:
	@make build
	@make run

VERSION=$(shell cat VERSION)
#building docker images for each service
build-db:
	@docker-compose build db
build-data:
	@docker-compose build data
build-web:
	@docker-compose build web
build-base:
	@docker build -t {{ project_name }}/base:$(VERSION) -f ./base/Dockerfile-base ./base
build-nginx:
	@docker-compose build nginx
build-testing:
	@docker-compose build testing
build: build-data build-db build-nginx build-base build-web build-testing


#run docker images
run-db:
	@docker-compose up data db
run-web:
	@docker-compose up web
run-nginx:
	@docker-compose up nginx
run-testing:
	@docker-compose up testing
run:
	@docker-compose up -d
# the only right way to run it on production
run-prod:
	@docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

#containers and images ids
CONTS-DB=$(shell docker ps -a -q -f "name={{ project_name }}-db")
IMGS-DB=$(shell docker images -q -f "label=application={{ project_name }}-db")

CONTS-DATA=$(shell docker ps -a -q -f "name={{ project_name }}-data")
IMGS-DATA=$(shell docker images -q -f "label=application={{ project_name }}-data")

CONTS-WEB=$(shell docker ps -a -q -f "name={{ project_name }}-web")
IMGS-WEB=$(shell docker images -q -f "label=application={{ project_name }}-web")

CONTS-NGINX=$(shell docker ps -a -q -f "name={{ project_name }}-nginx")
IMGS-NGINX=$(shell docker images -q -f "label=application={{ project_name }}-nginx")

IMGS-BASE=$(shell docker images -q -f "label=application={{ project_name }}-base")

CONTS-TESTING=$(shell docker ps -a -q -f "name={{ project_name }}-testing")
IMGS-TESTING=$(shell docker images -q -f "label=application={{ project_name }}-testing")

#stop docker containers
stop-db:
	-@docker stop $(CONTS-DB)
stop-data:
	-@docker stop $(CONTS-DATA)
stop-web:
	-@docker stop --time=1 $(CONTS-WEB)
stop-nginx:
	-@docker stop $(CONTS-NGINX)
stop-testing:
	-@docker stop $(CONTS-TESTING)
stop:
	@docker-compose down

#start docker containers
start-db:
	@docker start {{ project_name }}-data
	@docker start {{ project_name }}-db
start-web:
	@docker start {{ project_name }}-web
start-nginx:
	@docker start {{ project_name }}-nginx
start-testing:
	@docker start {{ project_name }}-testing
start: start-db start-web start-nginx start-testing

#remove docker containers
rm-data:
	-@docker rm $(CONTS-DATA)
rm-db:
	-@docker rm $(CONTS-DB)
rm-web:
	-@docker rm $(CONTS-WEB)
rm-nginx:
	-@docker rm $(CONTS-NGINX)
rm-testing:
	-@docker rm $(CONTS-TESTING)
rm: rm-db rm-web rm-nginx


#remove docker images
rmi-data:
	-@docker rmi -f $(IMGS-DATA)
rmi-db:
	-@docker rmi -f $(IMGS-DB)
rmi-web:
	-@docker rmi -f $(IMGS-WEB)
rmi-nginx:
	-@docker rmi -f $(IMGS-NGINX)
rmi-base:
	-@docker rmi -f $(IMGS-BASE)
rmi-testing:
	-@docker rmi -f $(IMGS-TESTING)
rmi: rmi-db rmi-web rmi-nginx


# stop containters, rmove containers, remove images
clean-db: stop-db rm-db rmi-db
clean-web: stop-web rm-web rmi-web
clean-nginx: stop-nginx rm-nginx rmi-nginx
clean-testing: stop-testing rm-testing rmi-testing
clean-apps: clean-db clean-web clean-nginx clean-testing
clean-base: rmi-base
clean-data: stop-data rm-data rmi-data
clean-compose:
	@docker-compose rm -f
clean-all: clean-db clean-web clean-nginx clean-testing clean-data clean-base clean-compose

reload-nginx:
	@make clean-nginx
	@make build-nginx
	@make run-nginx

# open shell in container
shell-web:
	@docker exec -it {{ project_name }}-web bash
shell-db:
	@docker exec -it {{ project_name }}-db bash
shell-testing:
	@docker exec -it {{ project_name }}-testing bash

logs:
	@docker-compose logs

# run sbe test in {{ project_name }}-web container
sbe:
	@docker exec -t {{ project_name }}-testing behave
