.. {{ project_name }} documentation master file, created by
   sphinx-quickstart on Tue Dec 29 19:06:20 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

For developers
=========================================

Installation
************

Below is description how to use it in local development and production.

Requirements for ElasticSearch to work.
---------------------------------------

In order to have ElasticSearch working you have to set on your host for {{ project_name }}-logs container::

  sudo sysctl -w vm.max_map_count=262144


On Ubuntu based host.
---------------------

When you will notice any network related problems (like being unable to reach internet during images building or from a built container; very slow network response within containers' network), check if in file on host machine::

  /etc/default/docker

you have uncommented::

  DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"

If you change this don't forget to restart docker-engine servie. For Ubuntu::

  sudo service docker restart

Local development
----------------- 

All what you need is to have `Docker Engine <https://docs.docker.com/>`_ and `Docker Compose <https://docs.docker.com/>`_   installed on your OS.
If you can read this doc you probably read README from {{ project_name }} project, but if not `check this <https://github.com/paterit/django-microservice-template>`_ out before further reading.


To build and run type::

    make

This will build your base images then with docker compose build and start all your containers.

To let docker-compose to build and run what is needed run::

    make run

To verify if all is up and running as planned you can run SBE tests::

    make sbe


Production
----------

TODO

Developing changes
******************

When all docker containers are up and running, what can be checked by runing::

  docker ps

You should see containers with names like::
  
  {{ project_name }}-db - PostgeSQL
  {{ project_name }}-web - Django application with Gunicorn
  {{ project_name }}-https - Nginx
  {{ project_name }}-testing - Behave, Selenium, PhantomJS
  {{ project_name }}-logs - ELK stack
  {{ project_name }}-logspout - Logspout - log forwarder from Docker to Logstash
  {{ project_name }}-docker-console - Portainer - web docker console
  {{ project_name }}-monitoring-agent - Glances - monitoring agent
  {{ project_name }}-monitoring-server - Graphit+Grafana - monitoring server


To stop all containers::

    make stop

And start them again::

    make start

Changes in web are dynamically reloaded after each change in code.
To reload https container run::

   make reload-https

to reload changes in docs run::

   make rebuild-docs

Short-cuts
**********

Makefile basicly covers all docker and docker-compose commands. Some of them can be useful like::

  make clean-apps

which stops and removes all containers and images build by docker-compose.
Additionally to clean up all images and containers run::

  make clean-all

If you the just run ::

  make

it will build and start all you need to have working {{ project_name }}.

To see all make commands with short description just run::

  make help

Docker shell
------------

To easily open shell for conteiners you can use::

    make shell-web
    make shell-https
    make shell-testing
    make shell-db
    make shell-logs
    make shell-docker-console


Logs
*******************

Logs from django and gunicorn are stored in volume container and written to /opt/{{ project_name }}/logs/web folder. You can access them by::

    make logs-web

Logs for Nginx are stored in volume container https-logs. You can access them by::

    make logs-https

Both web application's logs and Nginx' logs are transported to log collector container (ELK stack). You can analyze and watch them through `Kibana web intrface <http://127.0.0.1:5601/>`_.
Idea of delivering logs to logs collector is to have volume container for each application which logs should be transmitted to logs collector. Application is writing the logs to that container and in the same time the logs are delivered to stdout to transfer them to docker. From docker logs are shipped to Logstash with Logspout containter.


Monitoring
**********

For each docker-engine there is an instance of `Glances <https://nicolargo.github.io/glances/>`_ running. It sends monitoring data to `Graphite <https://graphiteapp.org/>`_ server via statsd protocol. From Graphite data are available in `Grafana <https://grafana.com/>`_ `dashboards <http:127.0.0.1:88>`_.

There are two dashboards:

- Glances - graphite: shows main system metrics for docker-engine host and containers
- Performance testing: useful to observe system behavior under performance testing


Performance testing
*******************

Performance testing is done with the `Locust <https://locust.io>`_ tool. To build your own tests change the file `locustfile.py` in `perf-testing` folder.


Local CI/CD machine
*******************

You can set up docker-machine and docker containers with buildbot which
will allow you to run and test your code with in docker-machine. Start
with::

    cd {{ project_name }}
    make cicd-local

To check if it runs propely verify if new containters are runing by
typing::

    docker ps

You should see among running containters with names like::

    {{ project_name }}-cicd-worker - Buildbot worker
    {{ project_name }}-cicd-master - Buidbot master
    {{ project_name }}-cicd-db - Buildbot database

Verify if docker-machine is running by typing::

    docker-machine ls

You should see among others machines one with the name::

    {{ project_name }}-cicd

Now you are able to use Buildbot through its `web
interface <http://localhost:8010/>`__. There are prepared
`builders <http://localhost:8010/#/builders>`__ that allows to build,
run and test all containers in docker-machine. 

For the first time you
have to run at least once "Full rebuild" builder. While runing it for
the first time couple GBs of data will be downloaded so it make take a
while. All base images for docker need to be downloaded to docker
machine (just to name a few: Python, PostgreSQL, ELK, Nginx).

If by any
chance you already have those images localy on your machine you can use
slightly faster way to copy them to your docker-machine. Simple bash
script to do that is stored in yor\_service project dir in the path:

::

    cicd/copy_docker_images_to_machine.sh

Now using IP generated for your docker-machine machine (in my case it is
192.168.99.100) you can start using your services. 

Here is the `Django admin panel <http://192.168.99.100/admin>`__ (user: admin, password: admin).

To read how it can be further used go to `docs <https://192.168.99.100/docs>`__. 

To see any other useful links go to `this page <https://127.0.0.1/docs/links_page.html>`__ in docs.

Whenever you do changes in your code, when you run any builders in Buildbot the fresh copy of your sources will be copied to Buildbot worker and tested.

Docker-engine context for cicd docker-machine
---------------------------------------------

To be able to call docker commands in the context of the docker-engine located on your {{ project_name }}-cicd docker-machine you need to set up propely environment variable for DOCKER. You can do it easily with:

::

    eval $(make set-docker-cicd)

be careful as for now all docker commands will be exectued on the docker engine located in your {{ project_name }}-cicd docker-machine.
To unset those variables and be back in the context of the local docker-engine simply type:

::

    eval $(make unset-docker)

Develop CI/CD machinery
-----------------------

If you need modify or add anything to CI/CD do changes in::

  cicd/master/config/master.cfg

When changes are ready you can run::

  make cicd-validate

to let Buildbot to verify your cfg file and then::

  make cicd-reconfig

to load changes into {{ project_name }}-cicd-worker container.

Testing
*******

BDD / SBE
---------

BDD is done with `behave <http://pythonhosted.org/behave/>`_. Steps should use only exposed REST API to make it technology agnostic.

To run SBE tests ::

    make sbe

How to write new SBE test with Behave
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the folder ``testing/features`` you will find files that holds test scenarios for different features. To add new one:

1. Create new file, eg ``next.features`` in the folder ``testing/features``
#. Put feature description and scenario in that file
#. Run::

    make sbe

#. Behave will print code snipet to use for @given @when @then to put in your ``steps`` files
#. Crate new file ``next.py`` int folder ``testing/features/steps``
#. Implement each steps
#. Run::

    make sbe

#. If all is there is read color - fix, if all is green you are done


Unit testing
------------

When you run ::

    make test

then the standard Django mechanism for testing will be fired inside your docker images. 

Base images
***********

There are couple of pre-built images used here to speed up the build process:

- locustio-alpine - for the ``perf-testing``
- sphinx-alpine - for the ``docs``
- node-behave-alpine - for the ``testing``
- django-postgresql-alpine2-python3.6.6-node3.8 - for the ``web``
- buildbot-worker-docker - for the ``cicd-worker``

The full repo names in hub.docer.com and current tags you can see in the ``cicd/build_base_images.sh`` script. 


Production
**********

to run in production mode use command::

    make run-prod

Documentation
*************

Generated by `Sphinx <http://sphinx-doc.org/>`_ with use of `reStructuredText <http://docutils.sourceforge.net/docs/user/rst/quickref.html>`_.

If you change documentation (``docs/source folder``) you can rebuild it in the container by ::

  make upload-docs

Source files of the docs are where code source lives in folder ``docs/source``. While running ``make upload-docs`` the docs source files are copied to {{ project_name }}-docs container where are compiled by Sphinx to html and then copied to Nginx to be served as a static files.


.. toctree::
   :maxdepth: 2



