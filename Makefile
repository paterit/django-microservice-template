# keeping for docker commands

all:
	@make build-base
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
	@bash build_pip_requirements.sh
	@docker build -t paterit/python-phantomjs -f ./base/Dockerfile-python-phantomjs ./base
	@docker build -t {{ project_name }}/base:$(VERSION) -f ./base/Dockerfile-base ./base
	@docker build -t {{ project_name }}/logs-data:$(VERSION) -f ./base/Dockerfile-logs-data ./base
build-https:
	@docker-compose build https
build-testing:
	@docker-compose build testing
build: build-data build-db build-https build-base build-web build-testing


#run docker images
run-db:
	@docker-compose up -d data db
run-web:
	@docker-compose up -d web
run-https:
	@docker-compose up -d https
run-testing:
	@docker-compose up -d testing
run-logs:
	@docker-compose up -d logs
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

CONTS-HTTPS=$(shell docker ps -a -q -f "name={{ project_name }}-https")
IMGS-HTTPS=$(shell docker images -q -f "label=application={{ project_name }}-https")

IMGS-BASE=$(shell docker images -q -f "label=application={{ project_name }}-base")

CONTS-TESTING=$(shell docker ps -a -q -f "name={{ project_name }}-testing")
IMGS-TESTING=$(shell docker images -q -f "label=application={{ project_name }}-testing")

CONTS-LOGS=$(shell docker ps -a -q -f "name={{ project_name }}-logs")
IMGS-LOGS=$(shell docker images -q -f "label=application={{ project_name }}-logs")

CONTS-LOGSPOUT=$(shell docker ps -a -q -f "name={{ project_name }}-logspout")
IMGS-LOGSPOUT=$(shell docker images -q -f "label=application={{ project_name }}-logspout")

#stop docker containers
stop-db:
	-@docker stop $(CONTS-DB)
stop-data:
	-@docker stop $(CONTS-DATA)
stop-web:
	-@docker stop --time=1 $(CONTS-WEB)
stop-https:
	-@docker stop $(CONTS-HTTPS)
stop-testing:
	-@docker stop $(CONTS-TESTING)
stop-logs:
	-@docker stop $(CONTS-LOGS)
stop-logspout:
	-@docker stop $(CONTS-LOGSPOUT)
stop:
	@docker-compose stop

#start docker containers
start-db:
	@docker start {{ project_name }}-data
	@docker start {{ project_name }}-db
start-web:
	@docker start {{ project_name }}-web
start-https:
	@docker start {{ project_name }}-https
start-testing:
	@docker start {{ project_name }}-testing
start-logs:
	@docker start {{ project_name }}-logs
start: 
	@docker-compose start

#remove docker containers
rm-data:
	-@docker rm $(CONTS-DATA)
rm-db:
	-@docker rm $(CONTS-DB)
rm-web:
	-@docker rm $(CONTS-WEB)
rm-https:
	-@docker rm $(CONTS-HTTPS)
rm-testing:
	-@docker rm $(CONTS-TESTING)
rm-logs:
	-@docker rm $(CONTS-LOGS)
rm-logspout:
	-@docker rm $(CONTS-LOGSPOUT)

rm: rm-db rm-web rm-https rm-logspout rm-logs


#remove docker images
rmi-data:
	-@docker rmi -f $(IMGS-DATA)
rmi-db:
	-@docker rmi -f $(IMGS-DB)
rmi-web:
	-@docker rmi -f $(IMGS-WEB)
rmi-https:
	-@docker rmi -f $(IMGS-HTTPS)
rmi-base:
	-@docker rmi -f $(IMGS-BASE)
rmi-testing:
	-@docker rmi -f $(IMGS-TESTING)
rmi-logs:
	-@docker rmi -f $(IMGS-LOGS)
rmi-logspout:
	-@docker rmi -f $(IMGS-LOGSPOUT)
rmi: rmi-db rmi-web rmi-https rmi-logspout rmi-logs


# stop containters, rmove containers, remove images
clean-db: stop-db rm-db rmi-db
clean-web: stop-web rm-web rmi-web
clean-https: stop-https rm-https rmi-https
clean-testing: stop-testing rm-testing rmi-testing
clean-apps: clean-db clean-web clean-https clean-testing
clean-base: rmi-base
clean-data: stop-data rm-data rmi-data
clean-logs: stop-logs rm-logs rmi-logs
clean-logspout: stop-logspout rm-logspout rmi-logspout
clean-compose:
	@docker-compose rm -f
clean-apps: clean-db clean-web clean-https clean-testing clean-logspout clean-logs clean-compose
clean-all: clean-apps clean-data clean-base

reload-https:
	@make clean-https
	@make build-https
	@make run-https

# open shell in container
shell-web:
	@docker exec -it {{ project_name }}-web bash
shell-db:
	@docker exec -it {{ project_name }}-db bash
shell-testing:
	@docker exec -it {{ project_name }}-testing bash
shell-logs:
	@docker exec -it {{ project_name }}-logs bash
shell-https:
	@docker exec -it {{ project_name }}-https bash

logs-web:
	@docker-compose logs -f | grep {{ project_name }}-web
logs-db:
	@docker-compose logs -f | grep {{ project_name }}-db
logs-https:
	@docker-compose logs -f | grep {{ project_name }}-https
logs-testing:
	@docker-compose logs -f | grep {{ project_name }}-testing
logs-logs:
	@docker-compose logs -f | grep {{ project_name }}-logs
logs:
	@docker-compose logs -f

# run sbe test in {{ project_name }}-web container
sbe:
	@docker exec -t {{ project_name }}-testing behave

build-docs:
	@docker exec -t {{ project_name }}-web bash -c 'cd ../docs; make html'

test:
	@docker exec -t {{ project_name }}-web python manage.py test --failfast

# Reload static files in web container
reload-static:
	@docker exec {{ project_name }}-web python manage.py collectstatic --no-input

# Reload static files automatically after every change.
dev-static:
	@when-changed -1 -v -r `find ./{{ project_name }}-web/* -name 'static'` -c make reload_static
