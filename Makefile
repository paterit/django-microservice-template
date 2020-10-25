
.EXPORT_ALL_VARIABLES:

## Build all containers and run tests with dev settings 
dev:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	sysctl vm.max_map_count | grep 262144 # sudo sysctl -w vm.max_map_count=262144
	make chmod-x
	make run
	make upload-docs
	make upload-static
	make wait-for-postgres
	make wait-for-elk
	make test
	make sbe-smoke
	make success-local


## Build all containers and run tests with production settings
all-prod:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	sysctl vm.max_map_count | grep 262144 # sudo sysctl -w vm.max_map_count=262144
	make chmod-x
	make run-prod
	make upload-docs
	make upload-static
	make wait-for-postgres
	make wait-for-elk
	make test
	make sbe-smoke
	make success-local

## Build and run containters on the remote docker machine
remote:
	cp ./remote.docker.env ./cicd/cicd.docker.env
	make cicd-local

## Set local docker-machine, creates Buildbot containers
dev-docker-machine:
	make cicd-set-local-docker-machine
	make cicd-local 


cicd-local:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	make chmod-x
	make run-cicd
	make cicd-wait-for-master
	make cicd-initial-commit
	make success-cicd

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
	bash cicd/pull_base_docker_images.sh
	bash cicd/copy_docker_images_to_machine.sh

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
## Build containers for docker console
build-docker-console:
	docker-compose build docker-console
## Build containers for monitoring agent
build-monitoring-agent:
	docker-compose build monitoring-agent
## Build containers for monitoring server
build-monitoring-server:
	docker-compose build monitoring-server
## Build containers for performance testing
build-perf:
	docker-compose build perf

## Build all applications' containers (without Buildbot)
build: build-data build-db build-https build-web build-docs build-testing build-docker-console build-monitoring build-perf

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
## Run container for ELK
run-logs:
	docker-compose up -d logs
## Run container for docker-console
run-docker-console:
	docker-compose up -d docker-console
## Run container for monitoring agent
run-monitoring-agent:
	docker-compose up -d monitoring-agent
## Run container for monitoring server
run-monitoring-server:
	docker-compose up -d monitoring-server
## Run container for performance testing
run-perf:
	docker-compose up -d perf
## Run all applications' containers (without Buildbot)
run:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	docker-compose up -d
## Run docker-machine and Buildbot containers
run-cicd:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	-docker-machine start {{ project_name }}-cicd
	docker-compose -f docker-compose.cicd.yml up -d
## Run all applications' containers with production dockr-compose file
run-prod:
	echo "DOCKER_HOST: " $(DOCKER_HOST) "TARGET: " $(TARGET)
	@echo "Start of make run-prod"
	@date +%T.%N
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
	@date +%T.%N
	@echo "End of make run-prod"

## Rebuild and run web
rerun-web:
	make build-web run-perf

## Rebuild and run performance testing
rerun-perf:
	make build-perf run-perf

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

CONTS-DOCKER-CONSOLE=$(shell docker ps -a -q -f "name={{ project_name }}-docker-console")
IMGS-DOCKER-CONSOLE=$(shell docker images -q -f "label=application={{ project_name }}-docker-console")

CONTS-MONITORING-AGENT=$(shell docker ps -a -q -f "name={{ project_name }}-monitoring-agent")
IMGS-MONITORING-AGENT=$(shell docker images -q -f "label=application={{ project_name }}-monitoring-agent")

CONTS-MONITORING-SERVER=$(shell docker ps -a -q -f "name={{ project_name }}-monitoring-server")
IMGS-MONITORING-SERVER=$(shell docker images -q -f "label=application={{ project_name }}-monitoring-server")

CONTS-PERF=$(shell docker ps -a -q -f "name={{ project_name }}-perf")
IMGS-PERF=$(shell docker images -q -f "label=application={{ project_name }}-perf")

CONTS-CICD=$(shell docker ps -a -q -f "name={{ project_name }}-cicd")

IMGS-CICD-MASTER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-master")
IMGS-CICD-WORKER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-worker")
IMGS-CICD-DB=$(shell docker images -q -f "label=application={{ project_name }}-cicd-db")

#stop docker containers
## Stop DB containers
stop-db:
	@echo $(CONTS-DB) | xargs -r docker stop
stop-data:
	@echo $(CONTS-DATA) | xargs -r docker stop
## Stop WEB application's containers
stop-web:
	@echo $(CONTS-WEB) | xargs -r docker stop --time=1
## Stop Nginx container
stop-https:
	@echo $(CONTS-HTTPS) | xargs -r docker stop
## Stop container for SBE testing
stop-testing:
	@echo $(CONTS-TESTING) | xargs -r docker stop
## Stop ELK conteiners
stop-logs:
	@echo $(CONTS-LOGS) | xargs -r docker stop
stop-logspout:
	@echo $(CONTS-LOGSPOUT) | xargs -r docker stop
## Stop docker console
stop-docker-console:
	@echo $(CONTS-DOCKER-CONSOLE) | xargs -r docker stop
## Stop monitoring server
stop-monitoring-server:
	@echo $(CONTS-MONITORING-SERVER) | xargs -r docker stop
## Stop monitoring agent
stop-monitoring-agent:
	@echo $(CONTS-MONITORING-AGENT) | xargs -r docker stop
## Stop performance testing
stop-perf:
	@echo $(CONTS-PERF) | xargs -r docker stop

## Stop Buildbot containers
stop-cicd:
	@echo $(CONTS-CICD) | xargs -r docker stop

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
## Start docker console container
start-docker-console:
	docker start {{ project_name }}-docker-console
## Start monitoring containers
start-monitoring:
	docker start {{ project_name }}-monitoring-agent
	docker start {{ project_name }}-monitoring-server
## Start performance testing containe
start-perf:
	docker start {{ project_name }}-perf
## Start all applications' containers (without Buildbot)
start: 
	docker-compose start
## Start all applications' containers with docker-compose production file
start-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml start

#remove docker containers
## Remove containers with data for DB
rm-data:
	@echo $(CONTS-DATA) | xargs -r docker rm
## Remove container with DB
rm-db:
	@echo $(CONTS-DB) | xargs -r docker rm
## Remove containers for WEB applications
rm-web:
	@echo $(CONTS-WEB) | xargs -r docker rm
## Remove containers for docs generation
rm-docs:
	@echo $(CONTS-DOCS) | xargs -r docker rm
## Remove container for Nginx
rm-https:
	@echo $(CONTS-HTTPS) | xargs -r docker rm
## Remove container for SBE testing
rm-testing:
	@echo $(CONTS-TESTING) | xargs -r docker rm
## Remove containers for ELK
rm-logs:
	@echo $(CONTS-LOGS) | xargs -r docker rm
rm-logspout:
	@echo $(CONTS-LOGSPOUT) | xargs -r docker rm
## Remove containers for docker-console
rm-docker-console:
	@echo $(CONTS-DOCKER-CONSOLE) | xargs -r docker rm
## Remove containers for monitoring-agent
rm-monitoring-agent:
	@echo $(CONTS-MONITORING-AGENT) | xargs -r docker rm
## Remove containers for monitoring-server
rm-monitoring-server:
	@echo $(CONTS-MONITORING-SERVER) | xargs -r docker rm
## Remove containers for performance testing
rm-perf:
	@echo $(CONTS-PERF) | xargs -r docker rm
## Remove containers for Buildbot
rm-cicd:
	@echo $(CONTS-CICD) | xargs -r docker rm
## Remove Buildbot database container
rm-cicd-db:
	@echo $(CONTS-CICD-DB) | xargs -r docker rm
## Remove all containers (with Buildbot)
rm: rm-db rm-web rm-docs rm-https rm-logspout rm-logs rm-docker-console rm-monitoring-agent rm-monitoring-server rm-perf rm-cicd


#remove docker images
## Remove docker images with data for DB
rmi-data:
	@echo $(IMGS-DATA) | xargs -r docker rmi -f
## Remove DB containers
rmi-db:
	@echo $(IMGS-DB) | xargs -r docker rmi -f
## Remove WEB app docker images
rmi-web:
	@echo $(IMGS-WEB) | xargs -r docker rmi -f
## Remove docker images for docs generation
rmi-docs:
	@echo $(IMGS-DOCS) | xargs -r docker rmi -f
## Remove docker images for Nginx
rmi-https:
	@echo $(IMGS-HTTPS) | xargs -r docker rmi -f
## Remove docker images for SBE testing
rmi-testing:
	@echo $(IMGS-TESTING) | xargs -r docker rmi -f
## Remove docker images for ELK
rmi-logs:
	@echo $(IMGS-LOGS) | xargs -r docker rmi -f
rmi-logspout:
	@echo $(IMGS-LOGSPOUT) | xargs -r docker rmi -f
## Remove docker images for docker console
rmi-docker-console:
	@echo $(IMGS-DOCKER-CONSOLE) | xargs -r docker rmi -f
## Remove docker images for monitoring-agent
rmi-monitoring-agent:
	@echo $(IMGS-MONITORING-AGENT) | xargs -r docker rmi -f
## Remove docker images for monitoring-server
rmi-monitoring-server:
	@echo $(IMGS-MONITORING-SERVER) | xargs -r docker rmi -f
## Remove docker images for performance testing
rmi-perf:
	@echo $(IMGS-PERF) | xargs -r docker rmi -f
## Remove  docker images for Buildbot apps and DB
rmi-cicd:
	@echo $(IMGS-CICD-MASTER) | xargs -r docker rmi -f
	@echo $(IMGS-CICD-WORKER) | xargs -r docker rmi -f
	@echo $(IMGS-CICD-DB) | xargs -r docker rmi -f
## Remove docker images for Buildbot DB
rmi-cicd-db:
	@echo $(IMGS-CICD-DB) | xargs -r docker rmi -f

## Remove all docker images, icluding Buildbot
rmi: rmi-db rmi-web rmi-https rmi-logspout rmi-logs rmi-docker-console rmi-monitoring-agent rmi-monitoring-server rmi-perf rmi-cicd

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
## Remove containers and docker images for docker console
clean-docker-console: stop-docker-console rm-docker-console rmi-docker-console
## Remove containers and docker images for monitoring agent
clean-monitoring-agent: stop-monitoring-agent rm-monitoring-agent rmi-monitoring-agent
## Remove containers and docker images for monitoring-server
clean-monitoring-server: stop-monitoring-server rm-monitoring-server rmi-monitoring-server
## Remove containers and docker images for performance testing
clean-perf: stop-perf rm-perf rmi-perf
## Remove containers and docker images for Buildbot
clean-cicd: stop-cicd rm-cicd rmi-cicd
clean-compose:
	docker-compose rm -f
## Remove ophaned docker volumes
clean-orphaned-volumes:
	@docker volume ls -qf dangling=true | xargs -r docker volume rm
## Remove images with <None> repository 
clean-none-images:
	@docker images --filter "dangling=true" -q --no-trunc | xargs -r docker rmi
	@docker images | awk '$$1~/<none>/ {print $$3}' | xargs -r docker rmi
## Remove containers and docker images for WEB application and SBE testing
clean-apps: clean-web clean-testing clean-docs clean-data #clean-compose - not work well in dmt-testing without virtenv context
## Remove containers and docker images for ELK, DB and Nginx
clean-non-apps: clean-logspout clean-logs clean-logspout clean-db clean-https clean-docker-console clean-monitoring-agent clean-monitoring-server clean-perf
## Remove all containers and docker images not including Buildbot 
clean-all: clean-apps clean-non-apps clean-data clean-docs clean-orphaned-volumes clean-none-images

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
## Open shell in container with performance testing
shell-perf:
	docker exec -it {{ project_name }}-perf bash
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
## View logs for docker console
logs-docker-console:
	docker logs -f {{ project_name }}-docker-console
## View logs for monitoring-agent
logs-monitoring-agent:
	docker logs -f {{ project_name }}-monitoring-agent
## View logs for monitoring-server
logs-monitoring-server:
	docker logs -f {{ project_name }}-monitoring-server
## View logs for performance testing
logs-perf:
	docker logs -f {{ project_name }}-perf

## Wait untill postgresql is ready
wait-for-postgres:
	docker exec -t {{ project_name }}-web python wait_for_postgres.py

## Wait untill ELK is ready (max 30s)
wait-for-elk:
	docker exec -t {{ project_name }}-logs bash -c "./wait_for_elk.sh"

# Wait utill Buildbot master is ready
wait-for-cicd-master:
	docker exec -t {{ project_name }}-cicd-master bash -c "./wait_for_master.sh"

## Run SBE tests
sbe:
	docker exec -t {{ project_name }}-testing behave --tags=smoketest,standard --no-skipped
## Run SBE moke tests
sbe-smoke:
	docker exec -t {{ project_name }}-testing behave --tags=smoketest  --no-skipped
## Run SBE performance tests
sbe-perf:
	docker-compose restart perf
	docker exec -t {{ project_name }}-testing behave --tags=perftest --no-skipped
## Run SBE preformance smoke tests
sbe-perf-smoke:
	docker exec -t {{ project_name }}-testing behave --tags=perfsmoke --no-skipped --no-logcapture

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

## Test if docs are compailed and propagated (only in local machine mode)
test-docs:
	sed -i "$$ a UploadTestSucced" ./docs/source/index.rst
	make upload-docs
	curl -Ls localhost/docs | grep UploadTestSucced
	sed -i "s|UploadTestSucced||g" ./docs/source/index.rst

## Test if docs are compailed and propagated (only in local docker-machine mode)
test-docs-cicd:
	sed -i "$$ a UploadTestSucced" ./docs/source/index.rst
	make upload-docs
	curl -Ls http://$(DOCKER_MACHINE_IP)/docs | grep UploadTestSucced && { exit 0; } || echo "Docs not updated!"; exit 1;
	sed -i "s|UploadTestSucced||g" ./docs/source/index.rst


## Collect static files in WEB container
reload-static:
	docker exec {{ project_name }}-web python manage.py collectstatic --no-input

## Reload static files automatically after every change.
dev-static:
	@when-changed -1 -v -r `find ./{{ project_name }}-web/* -name 'static'` -c make reload_static

## Docker compose down
down:
	docker-compose down

## Upload Buildbot config files and reload configuration
cicd-upload:
	docker cp ./cicd/master/config {{ project_name }}-cicd-master:/var/lib/buildbot
	-make cicd-reconfig
	make cicd-validate

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
	docker cp {{ project_name }}-docs:/opt/{{ project_name }}/docs/build/html ./docs/build/
	docker exec -t {{ project_name }}-https mkdir -p /opt/{{ project_name }}/docs/build
	docker cp ./docs/build/html {{ project_name }}-https:/opt/{{ project_name }}/docs/build/

## Collect static in WEB container and copy them to Nginx to be served as statics
upload-static:
	mkdir -p static
	make reload-static
	#docker exec -t {{ project_name }}-web python manage.py collectstatic --no-input
	docker cp {{ project_name }}-web:/opt/{{ project_name }}/static/ .
	docker cp ./static {{ project_name }}-https:/opt/{{ project_name }}/

## Unset env variables for docker engine cicd machine to use with eval $(make unset-docker)
unset-docker:
	unset DOCKER_TLS_VERIFY
	unset DOCKER_HOST
	unset DOCKER_CERT_PATH
	unset DOCKER_MACHINE_NAME
	unset DOCKER_MACHINE_IP

## Clean all built images on remote docker
clean-remote-docker-images:
	set -a; \
	. ./remote.docker.env; \
	set +a; \
	make clean-all

## Clean all built images on docker-machine
clean-docker-machine-images:
	set -a; \
	. ./docker-machine.docker.env; \
	set +a; \
	make clean-all

## Print message on success for local install
success-local:
	@echo "\033[1;32mGreat! All works! You can go to the docs - http://127.0.0.1/docs/ ).\033[0m"

## Print message on success for local with CI/CD machinery
success-cicd:
	@echo "\033[1;32mGreat! All works! You can go to the CI/CD console in your browser http://localhost:8010 .\033[0m"

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
