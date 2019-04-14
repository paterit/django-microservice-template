PROJECT_NAME = "yourservice"

default:
	make test-dev

## Clean code and virtualenv
clean-local:
	-make -C $(PROJECT_NAME) clean-pyc
	-make -C $(PROJECT_NAME) clean-all
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)
	rm -rf ./.git

## Mimic behavior describe in README.md as local development environment based on fresh copy from current ../sources
all-local:
	make prepare-local
	make initial-commit
	make run-local

## Create virtual env, copy source and create project in place
prepare-local:
	make virtualenv-pip
	make copy-current-dir
	make create-project

## Set virtualenv and install pip dependencies
virtualenv-pip:
	virtualenv -p /usr/bin/python3 virtenv
	. virtenv/bin/activate; \
	python --version; \
	pip install --upgrade pip; \
    pip install -r ../requirements.txt

## Copy source code from ../current dir
copy-current-dir:
	rsync -avq ../ ./dmt-template --exclude dmt-testing --exclude .git

## Call django-admin start project for code copied to local dmt-template dir
create-project:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=./dmt-template \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,locustfile.py,performance-testing.json,perf.py,glances-graphite.json,Dockerfile-perf,Dockerfile-glances,Dockerfile-grafana,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile,Dockerfile-docs,master.cfg,db.env,docker-machine.docker.env,post-commit \
        $(PROJECT_NAME)

## Initialize git repo and do initial commit to be able to track changes
initial-commit:
	git init
	git config --local user.email "dmt-testing@paterit.com"
	git config --local user.name "Awesome Django"
	git add .
	git commit -q -m "Initial commit."

## Run make all in the context of virtenv and PROJECT_NAME directory
run-local:
	. virtenv/bin/activate; \
	make -C $(PROJECT_NAME) dev


## Clean code, docker machine and virtualen
clean-docker-machine:
	-docker-machine start $(PROJECT_NAME)-cicd
	-make -C $(PROJECT_NAME) clean-docker-machine-images
	-docker-machine stop $(PROJECT_NAME)-cicd
	-make -C $(PROJECT_NAME) clean-cicd
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)

## Build and test with source code copied from ../current dir on local docker-machine
all-docker-machine:
	make virtualenv-pip
	make copy-current-dir
	make create-project
	. virtenv/bin/activate; \
	make -C $(PROJECT_NAME) dev-docker-machine
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	make success-docker-machine

## Clean code, remote docker machine and virtualenv
clean-remote:
	-make -C $(PROJECT_NAME) clean-remote-docker-images
	-make -C $(PROJECT_NAME) clean-cicd
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)


## Build and test with source code copied from ../current dir on remote docker machine
all-remote:
	make virtualenv-pip
	make copy-current-dir
	make create-project
	. virtenv/bin/activate; \
	make -C $(PROJECT_NAME) remote
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	make success-remote

## Build and test with source code cloned from github
all-git-docker-machine:
	make virtualenv-pip
	make create-project-git
	. virtenv/bin/activate; \
	make -C $(PROJECT_NAME) dev-docker-machine
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	make success-docker-machine

## Print message on success
success-remote:
	@echo "\033[1;32mGreat! All works! You can go to the remote docker address in the browser (as defined in remote.docker.env).\033[0m"


## Print message on success
success-docker-machine:
	@echo "\033[1;32mGreat! All works! You can go to the docker-machine address in the browser (most propably - http://192.168.99.100/docs/ ).\033[0m"


# ## Check if dokcer-machine for this PROJECT_NAME already exists
# check-docker-machine:
# 	@docker-machine ls | grep $(PROJECT_NAME) && { echo "Using existing: $(PROJECT_NAME) docker-machine!"; exit 0; } || exit 0;



## Call django-admin start project getting it from the github
create-project-git:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=https://github.com/paterit/django-microservice-template/archive/master.zip \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,locustfile.py,performance-testing.json,perf.py,glances-graphite.json,Dockerfile-perf,Dockerfile-glances,Dockerfile-grafana,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile,Dockerfile-docs,master.cfg,db.env,docker-machine.docker.env,post-commit \
        $(PROJECT_NAME)


## Create git repo and initial commit to triger git hook for full rebuild in Buildbot
cicd-initial-commit:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-initial-commit

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

# TODO: split into two: one for cicd, second for docker-machine - different TARGETS
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

## Run perormance tests
test-perf:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make sbe-perf

## Run django tests and sbe standard tests
test-sbe:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make test sbe

## Mimic behavior describe in README.md as local development environment
test-dev:
	make --no-print-directory clean-local
	make --no-print-directory all-local
	make --no-print-directory clean-local
	@echo "\033[1;32mGreat! Local build works!\033[0m"

test-docker-machine:
	make --no-print-directory clean-docker-machine
	make --no-print-directory all-docker-machine
	make --no-print-directory clean-docker-machine
	@echo "\033[1;32mGreat! Docker-machine version works!\033[0m"

test-remote:
	make --no-print-directory clean-remote
	make --no-print-directory all-remote
	make --no-print-directory clean-remote
	@echo "\033[1;32mGreat! Remote docker version works!\033[0m"

test-git:
	make --no-print-directory clean-docker-machine
	make --no-print-directory all-git-docker-machine
	make --no-print-directory clean-docker-machine
	@echo "\033[1;32mGreat! Docker-machine version from git works!\033[0m"

## Test both local and docker-machine versions
test:
	make test-dev
	make test-docker-machine
	make test-remote
	make test-git


hello:
	@echo "Hello!"

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
