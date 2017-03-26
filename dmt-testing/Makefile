PROJECT_NAME = "yourservice"

all-git:
	make prepare-env
	make create-project-git
	make build

all:
	make prepare-env
	make copy-current-dir
	make create-project
	make build

prepare-env:
	make clean
	make virtualenv
	make check-docker-machine

build:
	make build-cicd
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	#make clean
	make success

reload:
	rm -rf ./dmt-template
	rm -rf ./$(PROJECT_NAME)
	make copy-current-dir
	make create-project
	make reload-cicd-db
	#make reload-cicd
	make cicd-initial-commit
	make wait_for_full_rebuild
	make test_commit
	make wait_for_test_build
	make success

success:
	@echo "\033[1;32mGreat! All works!\033[0m."


clean:
	-cd $(PROJECT_NAME); \
	make clean-cicd
	-docker-machine stop $(PROJECT_NAME)-cicd
	-docker-machine rm -y $(PROJECT_NAME)-cicd
	rm -rf ./dmt-template
	rm -rf ./virtenv
	rm -rf ./$(PROJECT_NAME)

virtualenv:
	virtualenv -p /usr/bin/python3 virtenv
	. virtenv/bin/activate; \
	python --version; \
	pip install --upgrade pip; \
    pip install -r ../requirements.txt; \

check-docker-machine:
	@docker-machine ls | grep $(PROJECT_NAME) && { echo "Docker machine with this name: $(PROJECT_NAME) exists!"; exit 1; } || exit 0;

copy-current-dir:
	rsync -avq ../ ./dmt-template --exclude dmt-testing

create-project-git:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=https://github.com/paterit/django-microservice-template/archive/master.zip \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,Dockerfile-base,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile-logs-data,Dockerfile,master.cfg,db.env,cicd.docker.env,post-commit \
        $(PROJECT_NAME)

create-project:
	. virtenv/bin/activate; \
	django-admin startproject \
        --template=./dmt-template \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,Dockerfile-base,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile-logs-data,Dockerfile,master.cfg,db.env,cicd.docker.env,post-commit \
        $(PROJECT_NAME)

build-cicd:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-local

cicd-initial-commit:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-initial-commit

wait_for_full_rebuild:
	. virtenv/bin/activate; \
	python wait_for_build.py 1

wait_for_test_build:
	. virtenv/bin/activate; \
	python wait_for_build.py 2

reload-cicd-db:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-set-local-docker-machine; \
	make reload-cicd-db

reload-cicd:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	make cicd-set-local-docker-machine; \
	make clean-cicd; \
	make run-cicd; \
	make cicd-wait-for-master

test_commit:
	. virtenv/bin/activate; \
	cd $(PROJECT_NAME); \
	echo "Test commit." > test.txt; \
	git add test.txt; \
	git commit -q -m "Test commit."