# README #

### What is this repository for? ###

It is a django template for django-admin startproject that provides you contenerized (docker) components Postgresql + Django + Gunicorn + Nginx + SBE testing ready to add you services.

### How do I get set up? ###

You need Linux machine (tested on Ubuntu 14.04) with docker engine and virtualenv with Django.

Dependencies:

	Docker >= 1.12
	Docker-compose >= 1.8
	Django >= 1.10

Configuration:

	virtualenv -p /usr/bin/python3 virtenv

	source ./virtenv/bin/activate

	pip3 install Django==1.10

	pip3 install docker-compose==1.8

	django-admin startproject \
		--template=https://github.com/paterit/django-microservice-template/archive/master.zip \
		--extension=py,rst,yml,sh,md,conf,feature \
		--name=Makefile,Dockerfile-base,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-nginx,Dockerfile-testing \
		project_name

	cd project_name

Because chmod doesn't work from Dockerfile-web you need to add x permission to files:

	chmod +x project_name-web/web-development.sh

	chmod +x project_name-web/web-production.sh

	make build-base

	make run

To check if it runs propely verify if there are four new containters runing:

	project_name-testing
	project_name-web
	project_name-db
	project_name-nginx

If they are up and runing you shoul be able to se [admin panel](http://127.0.0.1/admin)

* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)