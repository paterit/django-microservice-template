## Build all containers and run tests with dev settings 
all:
	make chmod-x
	make run
	make upload-docs
	make upload-static
	make wait-for-postgres
	make wait-for-elk
	make test
	make sbe-smoke

## Build all containers and run tests with production settings
all-prod:
	make chmod-x
	make run-prod
	make upload-docs
	make upload-static
	make wait-for-postgres
	make wait-for-elk
	make test
	make sbe-smoke

## Set local docker-machine, creates Buildbot containers and run initial commit to fire git hook
cicd-local:
	make cicd-set-local-docker-machine
	bash cicd/pull_base_docker_images.sh
	-bash cicd/copy_docker_images_to_machine.sh
	make chmod-x
	make run-cicd
	make cicd-wait-for-master
	make cicd-initial-commit

# Set scripts as executable
chmod-x:
	chmod +x ./logs/wait_for_elk.sh
	chmod +x ./cicd/master/wait_for_master.sh
	chmod +x ./cicd/hooks/post-commit

## Initialize git repo and do initial commit to fire full rebuild in Buildbot via git hook
cicd-initial-commit:
	git init
	git config --local user.email "dmt@paterit.com"
	git config --local user.name "Awesome Django"
	ln -s -f ../../cicd/hooks/post-commit .git/hooks/post-commit
	git add .
	git commit -q -m "Initial commit."
	@echo ""
	@echo "Full rebuild has just started. You my verify progress at \033[1;33mhttp://localhost:8010/#/builders\033[0m."

## Set up local docker-machine if one does not exists
cicd-set-local-docker-machine:
	bash cicd/set_local_docker_machine.sh

## Wait until Buildbot master container is up and running
cicd-wait-for-master:
	docker exec -t {{ project_name }}-cicd-master bash -c "./wait_for_master.sh"

#building docker images for each service
## Build DB containers
build-db:
	docker-compose build db
build-data:
	docker-compose build data
## Build WEB application containers
build-web:
	docker-compose build web
## Build containers for docs generation
build-docs:
	docker-compose build docs
## Build Nginx container
build-https:
	docker-compose build https
## Build container for SBE tests
build-testing:
	docker-compose build testing
## Build containers for ELK
build-logs:
	docker-compose build logs
## Build all applications' containers (without Buildbot)
build: build-data build-db build-https build-web build-docs build-testing


#run docker images
## Run DB containers
run-db:
	docker-compose up -d data db
## Run WEB applicaton's containers
run-web:
	docker-compose up -d web
## Run Nginx container
run-https:
	docker-compose up -d https
## Run container for SBE testing
run-testing:
	docker-compose up -d testing
## Run containers for ELK
run-logs:
	docker-compose up -d logs
## Run all applications' containers (without Buildbot)
run:
	docker-compose up -d
## Run docker-machine and Buildbot containers
run-cicd:
	-docker-machine start {{ project_name }}-cicd
	docker-compose -f docker-compose.cicd.yml up -d
## Run all applications' containers with production dockr-compose file
run-prod:
	@echo "Start of make run-prod"
	@date +%T.%N
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@date +%T.%N
	@echo "End of make run-prod"

#containers and images ids
CONTS-DB=$(shell docker ps -a -q -f "name={{ project_name }}-db")
IMGS-DB=$(shell docker images -q -f "label=application={{ project_name }}-db")

CONTS-DATA=$(shell docker ps -a -q -f "name={{ project_name }}-data")
IMGS-DATA=$(shell docker images -q -f "label=application={{ project_name }}-data")

CONTS-WEB=$(shell docker ps -a -q -f "name={{ project_name }}-web")
IMGS-WEB=$(shell docker images -q -f "label=application={{ project_name }}-web")

CONTS-HTTPS=$(shell docker ps -a -q -f "name={{ project_name }}-https")
IMGS-HTTPS=$(shell docker images -q -f "label=application={{ project_name }}-https")

CONTS-TESTING=$(shell docker ps -a -q -f "name={{ project_name }}-testing")
IMGS-TESTING=$(shell docker images -q -f "label=application={{ project_name }}-testing")

CONTS-LOGS=$(shell docker ps -a -q -f "name={{ project_name }}-logs")
IMGS-LOGS=$(shell docker images -q -f "label=application={{ project_name }}-logs")

CONTS-LOGSPOUT=$(shell docker ps -a -q -f "name={{ project_name }}-logspout")
IMGS-LOGSPOUT=$(shell docker images -q -f "label=application={{ project_name }}-logspout")

CONTS-DOCS=$(shell docker ps -a -q -f "name={{ project_name }}-docs")
IMGS-DOCS=$(shell docker images -q -f "label=application={{ project_name }}-docs")

CONTS-CICD=$(shell docker ps -a -q -f "name={{ project_name }}-cicd")

IMGS-CICD-MASTER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-master")
IMGS-CICD-WORKER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-worker")
IMGS-CICD-DB=$(shell docker images -q -f "label=application={{ project_name }}-cicd-db")

#stop docker containers
## Stop DB containers
stop-db:
	-docker stop $(CONTS-DB)
stop-data:
	-docker stop $(CONTS-DATA)
## Stop WEB application's containers
stop-web:
	-docker stop --time=1 $(CONTS-WEB)
## Stop Nginx container
stop-https:
	-docker stop $(CONTS-HTTPS)
## Stop container for SBE testing
stop-testing:
	-docker stop $(CONTS-TESTING)
## Stop ELK conteiners
stop-logs:
	-docker stop $(CONTS-LOGS)
stop-logspout:
	-docker stop $(CONTS-LOGSPOUT)
## Stop Buildbot containers
stop-cicd:
	docker-compose -f docker-compose.cicd.yml stop
	docker-machine stop {{ project_name }}-cicd
## Stop all applications' containers (without Buildbot)
stop:
	docker-compose stop

#start docker containers
## Start DB containers
start-db:
	docker start {{ project_name }}-data
	docker start {{ project_name }}-db
## Start WEB application's container
start-web:
	docker start {{ project_name }}-web
## Start Nginx container
start-https:
	docker start {{ project_name }}-https
## Start container for SBE testing
start-testing:
	docker start {{ project_name }}-testing
## Start ELK containers
start-logs:
	docker start {{ project_name }}-logs
## Start all applications' containers (without Buildbot)
start: 
	docker-compose start
## Start all applications' containers with docker-compose production file
start-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml start

#remove docker containers
## Remove containers with data for DB
rm-data:
	-docker rm $(CONTS-DATA)
## Remove container with DB
rm-db:
	-docker rm $(CONTS-DB)
## Remove containers for WEB applications
rm-web:
	-docker rm $(CONTS-WEB)
## Remove containers for docs generation
rm-docs:
	-docker rm $(CONTS-DOCS)
## Remove container for Nginx
rm-https:
	-docker rm $(CONTS-HTTPS)
## Remove container for SBE testing
rm-testing:
	-docker rm $(CONTS-TESTING)
## Remove containers for ELK
rm-logs:
	-docker rm $(CONTS-LOGS)
rm-logspout:
	-docker rm $(CONTS-LOGSPOUT)
## Remove containers for Buildbot
rm-cicd:
	-docker rm $(CONTS-CICD)
## Remove Buildbot database container
rm-cicd-db:
	-docker rm {{ project_name }}-cicd-db
## Remove all containers (with Buildbot)
rm: rm-db rm-web rm-docs rm-https rm-logspout rm-logs rm-cicd


#remove docker images
## Remove docker images with data for DB
rmi-data:
	-docker rmi -f $(IMGS-DATA)
## Remove DB containers
rmi-db:
	-docker rmi -f $(IMGS-DB)
## Remove WEB app docker images
rmi-web:
	-docker rmi -f $(IMGS-WEB)
## Remove docker images for docs generation
rmi-docs:
	-docker rmi -f $(IMGS-DOCS)
## Remove docker images for Nginx
rmi-https:
	-docker rmi -f $(IMGS-HTTPS)
## Remove docker images for SBE testing
rmi-testing:
	-docker rmi -f $(IMGS-TESTING)
## Remove docker images for ELK
rmi-logs:
	-docker rmi -f $(IMGS-LOGS)
rmi-logspout:
	-docker rmi -f $(IMGS-LOGSPOUT)
## Remove  docker images for Buildbot apps and DB
rmi-cicd:
	-docker rmi -f $(IMGS-CICD-MASTER)
	-docker rmi -f $(IMGS-CICD-WORKER)
	-docker rmi -f $(IMGS-CICD-DB)
## Remove docker images for Buildbot DB
rmi-cicd-db:
	-docker rmi -f $(IMGS-CICD-DB)

## Remove all docker images, icluding Buildbot
rmi: rmi-db rmi-web rmi-https rmi-logspout rmi-logs rmi-cicd

## Remove compiled *.pyc files from the {{ project_name }}-web
clean-pyc: 
	docker exec -t {{ project_name }}-web rm -rf {{ project_name }}/__pycache__

# stop containters, rmove containers, remove images
## Remove containers and docker images for DB
clean-db: stop-db rm-db rmi-db
## Remove containers and docker images for WEB application
clean-web: stop-web rm-web rmi-web
## Remove containers and docker images for Nginx
clean-https: stop-https rm-https rmi-https
## Remove containers and docker images for SBE testing
clean-testing: stop-testing rm-testing rmi-testing
## Remove containers and docker images for docs generation
clean-docs: rm-docs rmi-docs
clean-data: stop-data rm-data rmi-data
## Remove containers and docker images for ELK
clean-logs: stop-logs rm-logs rmi-logs
clean-logspout: stop-logspout rm-logspout rmi-logspout
## Remove containers and docker images for Buildbot
clean-cicd: stop-cicd rm-cicd rmi-cicd
clean-compose:
	docker-compose rm -f
## Remove ophaned docker volumes
clean-orphaned-volumes:
	docker volume rm $(docker volume ls -qf dangling=true) || exit 0
## Remove images with <None> repository 
clean-none-images:
	-docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
## Remove containers and docker images for WEB application and SBE testing
clean-apps: clean-web clean-testing clean-docs clean-data clean-compose clean-orphaned-volumes
## Remove containers and docker images for ELK, DB and Nginx
clean-non-apps: clean-logspout clean-logs clean-logspout clean-db clean-https
## Remove all containers and docker images not including Buildbot 
clean-all: clean-apps clean-non-apps clean-data clean-docs

## Remove and recreate containers and docker images for Buildbot DB
reload-cicd-db:
	make stop-cicd
	make rm-cicd-db
	make rmi-cicd-db
	docker-compose -f docker-compose.cicd.yml up -d
	make cicd-wait-for-master

## Remove and recreate containers and docker iages for Nginx
reload-https:
	make clean-https
	make build-https
	make run-https

# open shell in container
## Open shell in container with WEB application
shell-web:
	docker exec -it {{ project_name }}-web bash
## Open shell in container with DB
shell-db:
	docker exec -it {{ project_name }}-db bash
## Open shell in container with SBE testing
shell-testing:
	docker exec -it {{ project_name }}-testing bash
## Open shell in container with ELK
shell-logs:
	docker exec -it {{ project_name }}-logs bash
## Open shell in container with Nginx
shell-https:
	docker exec -it {{ project_name }}-https bash
## Open shell in container with Buildbot master
shell-cicd-master:
	docker exec -it {{ project_name }}-cicd-master bash
## Open shell in container with Buildbot worker
shell-cicd-worker:
	docker exec -it {{ project_name }}-cicd-worker bash

## View logs for WEB application
logs-web:
	docker logs -f {{ project_name }}-web
## View logs for DB
logs-db:
	docker logs -f {{ project_name }}-db
## View logs for Nginx
logs-https:
	docker logs -f {{ project_name }}-https
## View logs for SBE testing
logs-testing:
	docker logs -f {{ project_name }}-testing
## View logs for ELK
logs-logs:
	docker logs -f {{ project_name }}-logs
## View logs for docs generation
logs-docs:
	docker logs -f {{ project_name }}-docs
## View logs for Buildbot master
logs-cicd-master:
	docker  logs -f {{ project_name }}-cicd-master
## View logs for Buildbot worker
logs-cicd-worker:
	docker  logs -f {{ project_name }}-cicd-worker
## View logs for Buildbot DB
logs-cicd-db:
	docker  logs -f {{ project_name }}-cicd-db

## Wait untill postgresql is ready
wait-for-postgres:
	docker exec -t {{ project_name }}-web python wait_for_postgres.py

## Wait untill ELK is ready (max 30s)
wait-for-elk:
	docker exec -t {{ project_name }}-logs bash -c "./wait_for_elk.sh"

# Wait utill Buildbot master is ready
wait-for-cicd-master:
	docker exec -t {{ project_name }}-cicd-master bash -c "./wait_for_master.sh"

## Run SBE tests in {{ project_name }}-web container
sbe:
	docker exec -t {{ project_name }}-testing behave
sbe-smoke:
	docker exec -t {{ project_name }}-testing behave --tags=smoketest

## Regenerate docs
rebuild-docs:
	docker start {{ project_name }}-docs

## Run WEB application tests (not SBE tests)
test:
	@echo "Start of make test"
	@date +%T.%N
	docker exec -t {{ project_name }}-web python manage.py test --failfast
	@date +%T.%N
	@echo "End of make test"

## Collect static files in WEB container
reload-static:
	docker exec {{ project_name }}-web python manage.py collectstatic --no-input

## Reload static files automatically after every change.
dev-static:
	@when-changed -1 -v -r `find ./{{ project_name }}-web/* -name 'static'` -c make reload_static

## Docker compose down
down:
	docker-compose down

## Reload Buildbot config files
cicd-reconfig:
	docker exec -t {{ project_name }}-cicd-master buildbot --verbose reconfig

## Validate Buildbot config file
cicd-validate:
	docker exec -t {{ project_name }}-cicd-master buildbot checkconfig master.cfg

## Regenerate docs and copy them to Nginx to be served as statics
upload-docs:
	docker cp ./docs {{ project_name }}-docs:/opt/{{ project_name }}/
	docker start -a {{ project_name }}-docs
	@mkdir -p ./docs/build
	docker cp {{ project_name }}-docs:/opt/{{ project_name }}/{{ project_name }}-docs/build/html ./docs/build/
	docker exec -t {{ project_name }}-https mkdir -p /opt/{{ project_name }}/docs/build
	docker cp ./docs/build/html {{ project_name }}-https:/opt/{{ project_name }}/docs/build/

## Collect static in WEB container and copy them to Nginx to be served as statics
upload-static:
	mkdir -p static
	make reload-static
	#docker exec -t {{ project_name }}-web python manage.py collectstatic --no-input
	docker cp {{ project_name }}-web:/opt/{{ project_name }}/static/ .
	docker cp ./static {{ project_name }}-https:/opt/{{ project_name }}/


# Printing nice help when make help is called

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20
## Show help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
