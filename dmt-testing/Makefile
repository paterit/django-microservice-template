PROJECT_NAME = "yourservice"


## Build and test with source code cloned from github
all-git: 
	make prepare-env
	make create-project-git
	make build

## Build and test with source code copied from ../current dir
all:
	make prepare-env
	make copy-current-dir
	make create-project
	make build

## Clean all and set up virtualenv and docker-machine
prepare-env:
	make clean
	make virtualenv
	make check-docker-machine

## Build CI/CD and start full rebuild and test build as an action triggered by post commit git hook
build:
	make build-cicd
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	#make clean
	make success


## Create virtual env, copy source and create project in place
prepare-local:
	make virtualenv
	make copy-current-dir
	make create-project

## Build local containers (not in docker-machine) based on fresh copy from current ../sources
all-local:
	make prepare-local
	make initial-commit
	make run-local
	
## Run make all in the context of virtenv and PROJECT_NAME directory
run-local:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make all

## Clean source dir and CI/CD database then copy fresh code from ../current dir and start full rebuild and test build as an action triggered by post commit git hook
reload:
	rm -rf ./dmt-template
	rm -rf ./$(PROJECT_NAME)
	make copy-current-dir
	make create-project
	make reload-cicd-db
	make cicd-initial-commit
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	make success

## Print message on success
success:
	@echo "\033[1;32mGreat! All works! You can go to the docker-machine address in your browser (most propably - http://192.168.99.100/docs/ ).\033[0m"

## Clean code, docker machine and virtualenv
clean:
	-cd $(PROJECT_NAME); \
	make clean-cicd
	-docker-machine stop $(PROJECT_NAME)-cicd
	-docker-machine rm -y $(PROJECT_NAME)-cicd
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)

## Clean code and virtualenv
clean-local:
	-cd $(PROJECT_NAME); \
	make clean-pyc; \
	make clean-all
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)
	rm -rf ./.git

## Set virtualenv
virtualenv:
	virtualenv -p /usr/bin/python3 virtenv
	. virtenv/bin/activate; \
	python --version; \
	pip install --upgrade pip; \
    pip install -r ../requirements.txt; \

## Check if dokcer-machine for this PROJECT_NAME already exists
check-docker-machine:
	@docker-machine ls | grep $(PROJECT_NAME) && { echo "Docker machine with this name: $(PROJECT_NAME) exists!"; exit 1; } || exit 0;

## Copy source code from ../current dir
copy-current-dir:
	rsync -avq ../ ./dmt-template --exclude dmt-testing --exclude .git

## Call django-admin start project getting it from the github
create-project-git:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=https://github.com/paterit/django-microservice-template/archive/master.zip \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,locustfile.py,performance-testing.json,perf.py,glances-graphite.json,Dockerfile-perf,Dockerfile-glances,Dockerfile-grafana,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile,Dockerfile-docs,master.cfg,db.env,cicd.docker.env,post-commit \
        $(PROJECT_NAME)

## Call django-admin start project for code copied to local dmt-template dir
create-project:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=./dmt-template \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,locustfile.py,performance-testing.json,perf.py,glances-graphite.json,Dockerfile-perf,Dockerfile-glances,Dockerfile-grafana,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile,Dockerfile-docs,master.cfg,db.env,cicd.docker.env,post-commit \
        $(PROJECT_NAME)

## Create docker containers with Buildbot
build-cicd:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-local

## Create git repo and initial commit to triger git hook for full rebuild in Buildbot
cicd-initial-commit:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-initial-commit

## Initialize git repo and do initial commit to be able to track changes
initial-commit:
	git init
	git config --local user.email "dmt-testing@paterit.com"
	git config --local user.name "Awesome Django"
	git add .
	git commit -q -m "Initial commit."

## Wait until the first full rebuild is done in Buildbot
wait_for_full_rebuild:
	. virtenv/bin/activate; \
	python wait_for_build.py 1

## Wait until the second build is done in Buildbot
wait_for_test_build:
	. virtenv/bin/activate; \
	python wait_for_build.py 2

## Set up docker-machine if not set and reloads Buildbot database
reload-cicd-db:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-set-local-docker-machine; \
	make reload-cicd-db

## Set up docker-machine if not set and reloads Buildbot containers and database
reload-cicd:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-set-local-docker-machine; \
	make clean-cicd; \
	make run-cicd; \
	make cicd-wait-for-master

## Create git dummy commit, to trigger git hooks
test_commit:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	echo "Test commit." >> test.txt; \
	git add test.txt; \
	git commit -q -m "Test commit."

## Test both local and docker-machine versions
test:
	make all-local
	make clean-local
	@echo "\033[1;32mGreat! Local build works!\033[0m"
	make all
	make clean
	@echo "\033[1;32mGreat! Docker-machine version works!\033[0m"
	make all-git
	make clean
	@echo "\033[1;32mGreat! Docker-machine version from git works!\033[0m"


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
