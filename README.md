# README #

It is a Django template for django-admin [startproject](https://docs.djangoproject.com/en/1.10/ref/django-admin/#startproject) command that provides you containerized ([docker](https://www.docker.com/)) sets of components cooperating together. The goal is to maximize the time for coding having all devops/pipeline/testing stuff ready to improve.
This project aims to be python centric, although there are some tools where good python replacement does not exist. Yet.

Currently there are couple of things set up and ready to be used and improved:
- Central logs aggregation with [ELK](https://www.elastic.co/products)
- Access to all containers logs and shells via simple `make` commands
- Performance testing with [Locust.io](https://locust.io) supported by SBE (via [Behave](http://pythonhosted.org/behave/))
- Monitoring of all components with [Glances](https://nicolargo.github.io/glances/) + [Graphite](https://graphiteapp.org/) + [Grafana](https://grafana.com/)
- SBE/BDD testing with [Behave](http://pythonhosted.org/behave/)
- Docker console with [Portainer](https://portainer.io/)
- Building docs for your services with [Sphinx](https://www.sphinx-doc.org)
- CI/CD pipline fired at local commits with [Buildbot](http://buildbot.net/)
- Plugged in service for you app based on [Django](https://www.djangoproject.com/) and supported by [Gunicorn](http://gunicorn.org/), [Nginx](https://nginx.org/), [Postgresql](https://www.postgresql.org/)

In the next releases:
- NoSql DB
- Key-value store
- Cache
- Persistent queues
- Alerting
- Load balancing 
- Service discovery
- API gateway
- Frontend with SSR (Vue.js)
- Event sourcing approach built in

### Set up an environment ###

You need Linux machine (tested on Ubuntu 18.04) with [docker engine](https://docs.docker.com/engine/), [make](http://www.gnu.org/software/make/), [virtualenv](https://virtualenv.pypa.io/en/stable/) with [Django](https://www.djangoproject.com/) and [docker-compose](https://docs.docker.com/compose/). If you want to set up CI-CD env locally then you need [docker-machine](https://docs.docker.com/machine/) and [Git](https://git-scm.com/) as well.

Dependencies:

    Docker >= 19.03
    Docker-compose >= 1.27
    Django >= 3.1
    Git >= 2.25

How to install docker see [here](https://docs.docker.com/engine/installation/).

Configuration for docker-compose and Django:

    python3 -m venv .venv
    source .venv/bin/activate
    python -m pip install Django==3.1 docker-compose==1.27 GitPython==3.1 requests==2.20
    python -m pip install --upgrade pip 
    
To create source code for your service based on this template you need to run:

    django-admin startproject \
        --template=https://github.com/paterit/django-microservice-template/archive/master.zip \
        --extension=py,rst,yml,sh,md,conf,feature \
        --name=Makefile,locustfile.py,performance-testing.json,perf.py,glances-graphite.json,Dockerfile-perf,Dockerfile-glances,Dockerfile-grafana,Dockerfile-docs,Dockerfile-web,Dockerfile-db,Dockerfile-data,Dockerfile-https,Dockerfile-testing,Dockerfile,master.cfg,db.env,docker-machine.docker.env,post-commit \
        yourservice

Due to docker-machine limits on naming machines don't use "_" (underscore) sign when naming your project.
Mainly due to resource-hungry ELK stack you should have at least 4GB of RAM on your dev machine.

### Building and running locally without CI/CD machinery (to use local CI/CD - jump to next section)
In order to have ElasticSearch (part of ELK stack) working on your machine you have to run:

    sudo sysctl -w vm.max_map_count=262144

Now you can download all needed docker images and build your containers just by typing make in yourservice directory:

    cd yourservice
    make

To check if it runs properly verify if new containers are running by typing:

    docker ps

You should see among running containers some with names like :

    yourservice-db - PostgeSQL
    yourservice-web - Django application with Gunicorn
    yourservice-https - Nginx
    yourservice-testing - Behave, Selenium, PhantomJS
    yourservice-logs - ELK stack
    yourservice-logspout - Logspout - log forwarder from Docker to Logstash
    yourservice-docker-console - Portainer - web docker console
    yourservice-monitoring-agent - Glances - monitoring agent
    yourservice-monitoring-server - Graphit+Grafana - monitoring server
    yourservice-https-logs - Logs for Nginx
    yourservice-web-logs - Logs for Django and Gunicorn

If they are up and running you should be able to see [admin panel](http://localhost/admin) (user: admin, password: admin)

To read how it can be used go to the [docs](http://localhost/docs).

To see any other useful links go to [this page](http://localhost/docs/links_page.html) in docs.

All of it creates a bunch of images and containers. But don't worry. It can be easily and safely cleaned up by running:

    make clean-all

### Building and running on local docker-machine with local CI/CD
To create a virtual machine with local CI/CD machinery you need to [install docker-machine](https://docs.docker.com/machine/install-machine/#install-machine-directly) and pv command ( `sudo apt-get install pv` ).
The following commands will set up local docker-machine and local docker containers with buildbot which will allow you to run and test your code within docker-machine. Start with:

    cd yourservice
    make dev-docker-machine

To check if it runs propelly verify if new containers are running by typing:

    docker ps

You should see among running containers some with names like :

    yourservice-cicd-worker - Buildbot worker
    yourservice-cicd-master - Buidbot master
    yourservice-cicd-db - Buildbot database
    
Verify if docker-machine is running by typing:

    docker-machine ls
    
You should see among others machines one with the name:

    yourservice-cicd
    
Now you are able to use Buildbot through its [web interface](http://localhost:8010/). There are prepared [builders](http://localhost:8010/#/builders) that allow to build, run and test all containers in docker-machine.
For the first time, you have to run at least once "Full rebuild" builder. While running it for the first time couple GBs of data will be downloaded so it may take a while. All base images for docker need to be downloaded to docker machine (just to name a few: Python, PostgreSQL, ELK, Nginx).
This "Full rebuild" builder should be already started (this is the last step in setting up local CICD env).
From now on whenever you commit any change locally to your project there will be message send to CICD via [post-commit hook](https://github.com/paterit/django-microservice-template/blob/master/cicd/hooks/post-commit) in your local git.

Now using IP generated for your docker-machine machine (in my case it is 192.168.99.100 - you can verify it by reading the output from docker-machine ls ) you can start using your services.
[Django admin panel](http://192.168.99.100/admin) (user: admin, password: admin)
To read how it can be further used go to [docs](http://192.168.99.100/docs).
To see any other useful links go to [this page](http://192.168.99.100/docs/links_page.html) in docs.

Whenever you do changes in your code, when you run any builders in Buildbot the fresh copy of your sources will be copied to Buildbot worker and tested.

To clean CICD containers from run:

    make clean-cicd

A bunch of images and containers exists in docker-machine. It can be easily and safely cleaned up by running (it will neither stop or remove docker-machine itself):

    make clean-docker-machine

To stop or remove docker machine type either:

    docker-machine stop yourservice-cicd

or:

    docker-machine rm yourservice-cicd

### Building and running on remote docker host with local CI/CD
The following commands will set up local containers with buildbot which will allow you to run and test your code within remote docker host. Environment variables to connect CICD to remote docker host should be defined in file `remote.docker.env`. In order to have ElasticSearch (part of ELK stack) working on your remote docker machine you have to run on its host OS:

    sudo sysctl -w vm.max_map_count=262144

Then continue on your local machine:

    cd yourservice
    make remote

To check if it runs propelly verify if new containers are running by typing:

    docker ps

You should see among running containers some with names like :

    yourservice-cicd-worker - Buildbot worker
    yourservice-cicd-master - Buidbot master
    yourservice-cicd-db - Buildbot database

Now you are able to use Buildbot through its [web interface](http://localhost:8010/). There are prepared [builders](http://localhost:8010/#/builders) that allow to build, run and test all containers in docker-machine.
For the first time, you have to run at least once "Full rebuild" builder. While running it for the first time couple GBs of data will be downloaded so it may take a while. All base images for docker need to be downloaded to docker machine (just to name a few: Python, PostgreSQL, ELK, Nginx).
This "Full rebuild" builder should be already started (this is the last step in setting up local CICD env).
From now on whenever you commit any change locally to your project there will be message send to CICD via post-commit hook in Git.

Now with remote docker IP you can start using your services.
[Django admin panel](REMOTE_IP/admin) (user: admin, password: admin)
To read how it can be further used go to [docs](REMOTE_IP/docs).
To see any other useful links go to [this page](REMOTE_IP/docs/links_page.html) in docs.

Whenever you do changes in your code, when you run any builders in Buildbot the fresh copy of your sources will be copied to Buildbot worker and tested.

To clean CICD containers from run:

    make clean-cicd

A bunch of images and containers exists on the remote docker host. It can be easily and safely cleaned up by running:

    make clean-remote-docker-images


* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)
