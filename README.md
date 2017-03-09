# README #

It is a django template for django-admin [startproject](https://docs.djangoproject.com/en/1.10/ref/django-admin/#startproject) command that provides you contenerized ([docker](https://www.docker.com/)) sets of components cooperating toghether which should allow you to focus mainly on the code and solving problem you want to solve.
This project aims to be python centric, although there are some tools where good python replacement does not exit. Yet.

Currently available components to build your services:
- Relational DB: [Postgresql](https://www.postgresql.org/)
- Web application: [Django](https://www.djangoproject.com/) + [Gunicorn](http://gunicorn.org/) (HA component)
- Http server: [Nginx](https://nginx.org/) (HA component)
- Balckbox testing: SBE by [Behave](http://pythonhosted.org/behave/)
- Logs aggreagator: [ELK](https://www.elastic.co/products) stack
- CI/CD machinery: [Buildbot](http://buildbot.net/)

Planned to be added:
- Performacne testing
- Monitoring
- NoSql DB
- Key-value store
- Cache
- Persistent queues (HA component)
- Docker swarm
- Alerting
- Load balancing (HA component)
- Service discovery
- API gateway (HA component)

### How do I get set up? ###

You need Linux machine (tested on Ubuntu 14.04) with [docker engine](https://docs.docker.com/engine/), [virtualenv](https://virtualenv.pypa.io/en/stable/) with [Django](https://www.djangoproject.com/) and [docker-compose](https://docs.docker.com/compose/). If you want to set up CI-CD env locally, than you need [docker-machine](https://docs.docker.com/machine/) as well.

Dependencies:

	Docker >= 1.12.5
	Docker-compose >= 1.8
	Django >= 1.10

How to insall docker see [here](https://docs.docker.com/engine/installation/).

Configuration for docker-compose and Django:

	virtualenv -p /usr/bin/python3 virtenv
	source ./virtenv/bin/activate
	pip install Django==1.10
	pip install docker-compose==1.8
To create source code for your service based on this template you need to run:

	django-admin startproject \
		--template=https://github.com/paterit/django-microservice-template/archive/master.zip \
		--extension=py,rst,yml,sh,md,conf,feature \
		--name=Makefile,Dockerfile-base,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile-logs-data,Dockerfile,master.cfg,db.env,cicd.docker.env \
		your_service

Mainly due to resource hungry ELK stack you should have at least 4GB of RAM on your dev machine.

### Building and running localy without CI/CD machinery (to use local CI/CD - jump to next section)
In order to have ElasticSearch (part of ELK stack) working on your machine you have to run:

    sudo sysctl -w vm.max_map_count=262144

Now you can download all needed docker images and build your conteiners just by typing make in your_service directory:

    cd your_service
	make

To check if it runs propely verify if new containters are runing by typing:

	docker ps

You should see among running containters some with names like :

	your_service-db - PostgeSQL
	your_service-web - Django application with Gunicorn
	your_service-https - Nginx
	your_service-testing - Behave, Selenium, PhantomJS
	your_service-logs - ELK stack
	your_service-logspout - Logspout - log forwarder from Docker to Logstash

And couple of data containers to better manage logs:

    your_service-https-logs - Logs for Nginx
    your_service-web-logs - Logs for Django and Gunicorn

If they are up and runing you shoul be able to se [admin panel](http://127.0.0.1/admin)

To read how it can be used go to [docs](https://127.0.0.1/docs).

To see any other useful links go to [docs](https://127.0.0.1/docs/links_page.html).

### Building and running localy with CI/CD machinery
It will set up docker-machine and docker containers with buildbot which will allows you to run and test your code with in docker-machine. Start with:

    cd your_service
	make cicd-local

To check if it runs propely verify if new containters are runing by typing:

	docker ps

You should see among running containters with names like :

    your_service-cicd-worker - Buildbot worker
    your_service-cicd-master - Buidbot master
    your_service-cicd-db - Buildbot database
    
Verify if docker-machine is running by typing:

    docker-machine ls
    
You should see among others machines one with the name:

    your_service-cicd
    
Now you are able to use Buildbot through its [web interface](http://localhost:8010/). There are prepared [builders](http://localhost:8010/#/builders) that allows to build, run and test all containers in docker-machine.
For the first time you have to run at least once "Full rebuild" builder. While runing it for the first time couple GBs of data will be downloaded so it make take a while. All base images for docker need to be downloaded to docker machine (just to name a few: Python, PostgreSQL, ELK, Nginx).
If by any chance you already have those images localy on your machine you can use slightly faster way to copy them to your docker-machine. Simple bash script to do that is stored in yor_service project dir in the path:

    cicd/copy_docker_images_to_machine.sh

Now using IP generated for your docker-machine machine (in my case it is 192.168.99.100) you can start using your services.
[Django admin panel](http://192.168.99.100/admin)
To read how it can be further used go to [docs](https://192.168.99.100/docs).
To see any other useful links go to [this page](https://127.0.0.1/docs/links_page.html) in docs.

Whenever you do changes in your code, when you run any builders in Buildbot the fresh copy of your sources will be copied to Buildbot worker and tested.


* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)
