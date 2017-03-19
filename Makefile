# keeping for docker commands

all:
	@make build-base
	@make run

all-prod:
	@make build-base
	@make run-prod

cicd-local:
	bash cicd/set_local_docker_machine.sh
	bash cicd/copy_docker_images_to_machine.sh
	@chmod +x ./logs/wait_for_elk.sh
    @chmod +x ./cicd/master/wait_for_master.sh
    @chmod +x ./cicd/hooks/post-commit
	@make run-cicd
	@docker exec -t {{ project_name }}-cicd-master bash -c "./wait_for_master.sh"
	@git init
	@ln -s -f ../../cicd/hooks/post-commit .git/hooks/post-commit
	@git add .
	@git commit -q -m "Initial commit."
	@echo ""
	@echo "Full rebuild has just started. You my verify progress at \033[1;33mhttp://localhost:8010/#/builders\033[0m."

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
run-cicd:
	-@docker-machine start {{ project_name }}-cicd
	@docker-compose -f docker-compose.cicd.yml up -d
run-prod:
	@echo "Start of make run-prod"
	@date +%T.%N
	@docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
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

IMGS-BASE=$(shell docker images -q -f "label=application={{ project_name }}-base")

CONTS-TESTING=$(shell docker ps -a -q -f "name={{ project_name }}-testing")
IMGS-TESTING=$(shell docker images -q -f "label=application={{ project_name }}-testing")

CONTS-LOGS=$(shell docker ps -a -q -f "name={{ project_name }}-logs")
IMGS-LOGS=$(shell docker images -q -f "label=application={{ project_name }}-logs")

CONTS-LOGSPOUT=$(shell docker ps -a -q -f "name={{ project_name }}-logspout")
IMGS-LOGSPOUT=$(shell docker images -q -f "label=application={{ project_name }}-logspout")

CONTS-CICD=$(shell docker ps -a -q -f "name={{ project_name }}-cicd")

IMGS-CICD-MASTER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-master")
IMGS-CICD-WORKER=$(shell docker images -q -f "label=application={{ project_name }}-cicd-worker")
IMGS-CICD-DB=$(shell docker images -q -f "label=application={{ project_name }}-cicd-db")

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
stop-cicd:
	@docker-compose -f docker-compose.cicd.yml stop
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
rm-cicd:
	-@docker rm $(CONTS-CICD)

rm: rm-db rm-web rm-https rm-logspout rm-logs rm-cicd


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
rmi-cicd:
	-@docker rmi -f $(IMGS-CICD-MASTER)
	-@docker rmi -f $(IMGS-CICD-WORKER)
	-@docker rmi -f $(IMGS-CICD-DB)

rmi: rmi-db rmi-web rmi-https rmi-logspout rmi-logs rmi-cicd


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
clean-cicd: stop-cicd rm-cicd rmi-cicd
clean-compose:
	@docker-compose rm -f
clean-orphaned-volumes:
	@docker volume rm $(docker volume ls -qf dangling=true) || exit 0
clean-apps: clean-web clean-testing clean-compose clean-orphaned-volumes
clean-non-apps: clean-logspout clean-logs clean-db clean-https 
clean-all: clean-apps clean-non-apps clean-data clean-base
clean-cicd: clean-cicd

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
shell-cicd-master:
	@docker exec -it {{ project_name }}-cicd-master bash
shell-cicd-worker:
	@docker exec -it {{ project_name }}-cicd-worker bash

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
logs-cicd:
	@docker-compose -f docker-compose.cicd.yml logs -f --tail 20 | grep {{ project_name }}-cicd | grep -v {{ project_name }}-cicd-db
logs:
	@docker-compose logs -f

# wait till postgresql is ready
wait-for-postgres:
	@docker exec -t {{ project_name }}-web python wait_for_postgres.py

# wait till elastic is ready (max 30s)
wait-for-elk:
	@docker exec -t {{ project_name }}-logs bash -c "./wait_for_elk.sh"

# wait till cicd master is ready
wait-for-cicd-master:
	@docker exec -t {{ project_name }}-cicd-master bash -c "./wait_for_master.sh"

# run sbe test in {{ project_name }}-web container
sbe:
	@docker exec -t {{ project_name }}-testing behave

build-docs:
	@docker exec -t {{ project_name }}-web bash -c 'cd ../docs; make html'

test:
	@echo "Start of make test"
	@date +%T.%N
	@docker exec -t {{ project_name }}-web python manage.py test --failfast
	@date +%T.%N
	@echo "End of make test"

# Reload static files in web container
reload-static:
	@docker exec {{ project_name }}-web python manage.py collectstatic --no-input

# Reload static files automatically after every change.
dev-static:
	@when-changed -1 -v -r `find ./{{ project_name }}-web/* -name 'static'` -c make reload_static

down:
	@docker-compose down

cicd-reconfig:
	@docker exec -t {{ project_name }}-cicd-master buildbot --verbose reconfig

cicd-validate:
	@docker exec -t {{ project_name }}-cicd-master buildbot checkconfig master.cfg

upload-docs:
	@docker cp ./docs {{ project_name }}-web:/opt/{{ project_name }}/
	@docker exec -t {{ project_name }}-web bash -c 'cd ../docs; make html'
	@mkdir -p ./docs/build
	@docker cp {{ project_name }}-web:/opt/{{ project_name }}/docs/build/html ./docs/build/
	@docker exec -t {{ project_name }}-https mkdir -p /opt/{{ project_name }}/docs/build
	@docker cp ./docs/build/html {{ project_name }}-https:/opt/{{ project_name }}/docs/build/

upload-static:
	mkdir -p static
	@docker exec -t {{ project_name }}-web python manage.py collectstatic --no-input
	@docker cp {{ project_name }}-web:/opt/{{ project_name }}/static/ .
	@docker cp ./static {{ project_name }}-https:/opt/{{ project_name }}/
