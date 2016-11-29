# README #

It is a django template for django-admin [startproject](https://docs.djangoproject.com/en/1.10/ref/django-admin/#startproject) command that provides you contenerized ([docker](https://www.docker.com/)) components: DB ([Postgresql](https://www.postgresql.org/)) + WebApp ([Django](https://www.djangoproject.com/) + [Gunicorn](http://gunicorn.org/)) + http server ([Nginx](https://nginx.org/)) + balckbox testing (SBE by [behave](http://pythonhosted.org/behave/)) ready to add you services.

### How do I get set up? ###

You need Linux machine (tested on Ubuntu 14.04) with docker engine and virtualenv with Django and docker-compose.

Dependencies:

	Docker >= 1.12.3
	Docker-compose >= 1.8
	Django >= 1.10

How to insall docker see [here](https://docs.docker.com/engine/installation/).

Configuration for Docker-compose and Django:

	virtualenv -p /usr/bin/python3 virtenv

	source ./virtenv/bin/activate

	pip install Django==1.10

	pip install docker-compose==1.8

	django-admin startproject \
		--template=https://github.com/paterit/django-microservice-template/archive/master.zip \
		--extension=py,rst,yml,sh,md,conf,feature \
		--name=Makefile,Dockerfile-base,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile-logs-data,Dockerfile \
		project_name

	cd project_name

Building and running:

	make

To check if it runs propely verify if new containters are runing by typing:

	docker ps

You should see among running containters four with names like :

	project_name-db - PostgeSQL
	project_name-web - Django application with gunicorn
	project_name-https - Nginx
	project_name-testing - Behave, Selenium, PhantomJS
	project_name-logs - ELK stack
	project_name-logspout - Logspout - log forwarder from Docker to Logstash

If they are up and runing you shoul be able to se [admin panel](http://127.0.0.1/admin)

To read how it can be used go to [docs](https://127.0.0.1/docs).

To see any other useful links go to [docs](https://127.0.0.1/docs/links_page.html).

* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)
