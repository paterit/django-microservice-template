PROJECT_NAME = "yourservice"

all:
	make clean
	make virtualenv
	make check-docker-machine
	make copy-current-dir
	make create-project
	make build-cicd

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