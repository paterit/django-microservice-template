

Installation and configuration
==============================

.. contents:: Table of Contents
   :depth: 1
   :local:

Installation
************

Below is a description how to use it in local development and production.

Requirements for ElasticSearch to work.
---------------------------------------

In order to have ElasticSearch working you have to set on your OS host for {{ project_name }}-logs container::

  sudo sysctl -w vm.max_map_count=262144


Local development
----------------- 

All what you need is to have `Docker Engine <https://docs.docker.com/>`_ and `Docker Compose <https://docs.docker.com/compose/>`_   installed on your OS.
If you can read this doc you probably heave read README from {{ project_name }} project, but if not `check this <https://github.com/paterit/django-microservice-template>`_ out before further reading.


To build and run type::

    make

This will build your base images then with the docker-compose build and start all your containers.

To let docker-compose to build and run what is needed run::

    make run

To verify if all is up and running as planned you can run SBE tests::

    make sbe


Production
----------

TODO

Developing changes
******************

When all docker containers are up and running, what can be checked by running::

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
  {{ project_name }}-perf - Locust - performance testing


To stop all containers::

    make stop

And start them again::

    make start

Changes in web and SBE tests are dynamically reloaded after each change in code.
To reload https container run::

   make reload-https

to reload changes in docs run::

   make upload-docs

to reload changes in Locust run::

   make rerun-perf

Short-cuts
**********

Makefile basically covers all docker and docker-compose commands. Some of them can be useful like::

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

To easily open the shell for containers you can use::

    make shell-web
    make shell-https
    make shell-testing

    and so on

to see all shell make commands you can run ``make help | grep shell-``


Logs
*******************

Logs from Django and gunicorn are stored in volume container and written to /opt/{{ project_name }}/logs/web folder. You can access them by::

    make logs-web

Logs for Nginx are stored in volume container https-logs. You can access them by::

    make logs-https

Both web application's logs and Nginx' logs are transported to the logs collector container (ELK stack). You can analyze and watch them through `Kibana web interface <http://127.0.0.1:5601/>`_.
The idea of delivering logs to the logs collector is to have a volume container for each application which logs should be transmitted to the logs collector. Application is writing the logs to that container and in the same time the logs are delivered to stdout to transfer them to docker. From docker logs are shipped to Logstash with Logspout container.


Monitoring
**********

For each docker-engine there is an instance of `Glances <https://nicolargo.github.io/glances/>`_ running. It sends monitoring data to `Graphite <https://graphiteapp.org/>`_ server via statsd protocol. From Graphite data are available in `Grafana <https://grafana.com/>`_ `dashboards <http:127.0.0.1:88>`_.

There are two dashboards:

- Glances - graphite: shows main system metrics for docker-engine host and containers
- Performance testing: useful to observe system behavior under performance testing


Performance testing
*******************

Performance testing is done with the `Locust <https://locust.io>`_ tool. To build your own tests change the file ``locustfile.py`` in ``perf-testing`` folder.

The current configuration allows you to define basic performance tests as SBE tests with Behave. Take a look at ``testing/features/perf.feature`` file to see how it works.

To run performance tests you may run::

  make sbe-perf

Container with Locust will be rebooted (Locust's problem with hungry memory allocation) and the SBE test will be run. If you go to Grafana ("Performance testing" dashboard) you can see basic statistics regarding your tests like: response time, requests per second, CPU and memory usage on containers.


Local CI/CD with local docker-machine or remote docker host
***********************************************************

You can set up docker-machine and Docker containers with buildbot which
will allow you to run and test your code with in docker-machine. Start
with::

    cd {{ project_name }}
    make dev-docker-machine

To check if it runs properly verify if new containers are running by
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

Now you are able to use Buildbot through its `web interface <http://localhost:8010/>`__. There are prepared `builders <http://localhost:8010/#/builders>`__ that allows to build,
run and test all containers in docker-machine. 

For the first time you have to run at least once "Full rebuild" builder. While running it for
the first time couple GBs of data will be downloaded so it make take a
while. All base images for docker need to be downloaded to docker-machine (just to name a few: Python, PostgreSQL, ELK, Nginx).

If by any chance you already have those images locally on your machine you can use
a slightly faster way to copy them to your docker-machine. Simple bash
script to do that is stored in yor\_service project dir in the path:


::

    cicd/copy_docker_images_to_machine.sh

Now using IP generated for your docker-machine machine (in my case it is
192.168.99.100) you can start using your services. 

Here is the `Django admin panel <http://192.168.99.100/admin>`__ (user: admin, password: admin).

To read how it can be further used go to `docs <http://192.168.99.100/docs>`__. 

To see any other useful links go to `this page <http://127.0.0.1/docs/links_page.html>`__ in docs.

Whenever you do changes in your code, when you run any builders in Buildbot the fresh copy of your sources will be copied to Buildbot worker and tested.

Remote docker host
------------------

If instead of `make dev-docker-machine` you run::

    make remote

then your services will be built and run on a remote docker host (as defined in remote.docker.env). To use a secure connection to your remote Docker host from CI/CD put your remote docker TLS certificates (ca.pem, cert.pem, key.pem) into `cicd/worker/certs` folders. Don't forget to set in remote.docker.env for the DOCKER_MACHINE_NAME value aligned with your certificates. If you don't use a secure connection to your remote machine, leave in the remote.docker.env only DOCKER_HOST value.

To create certificates on you remote docker host you can use `this tool <https://github.com/paulczar/omgwtfssl>`__ .

`Here <https://docs.docker.com/engine/security/https/>`__ you can find more on securing the connection to your docker host.

In order to have ElasticSearch working you have to set on your remote docker OS host

::

  sudo sysctl -w vm.max_map_count=262144

The docker-engine context for cicd docker-machine
-------------------------------------------------

To be able to call docker commands in the context of the docker-engine located on your {{ project_name }}-cicd docker-machine you need to set up properly environment variable for DOCKER. You can do it by loading environment variables defined in the `docker-machine.docker.env` file:

::

    set -a
    . ./docker-machine.docker.env
    set +a

be careful as for now all docker commands will be executed on the docker engine located in your {{ project_name }}-cicd docker-machine.

Fore remote docker host you can use the `remote.docker.env` file. Just remember that ``DOCKER_CERT_PATH`` in this file needs to be valid absolute
path to certs on the remote docker host.

::

    set -a
    . ./remote.docker.env
    set +a
    

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

Tests are tagged with:

- @smoketest - those should be test that run quickly and allows to verify if all main parts are alive and connected
- @perf - performance tests, usually not that fast
- @slow - any test that takes more then 10 secs to execute
- @standard - when run make sbe all tests with @standard and @smoketest are run

How to write a new SBE test with Behave
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the folder ``testing/features`` you will find files that holds test scenarios for different features. To add a new one:

1. Create a new file, eg ``next.features`` in the folder ``testing/features``
#. Put feature description and scenario in that file
#. Run::

    make sbe

#. Behave will print code snippet to use for @given @when @then to put in your ``steps`` files
#. Crate new file ``next.py`` int folder ``testing/features/steps``
#. Implement each step
#. Run::

    make sbe

#. If all is there is read color - fix, if all is green you are done


Unit testing
------------

When you run ::

    make test

then the standard Django mechanism for testing will be fired inside your docker images. 



Production
**********


Documentation
*************

Generated by `Sphinx <http://sphinx-doc.org/>`_ with use of `reStructuredText <http://docutils.sourceforge.net/docs/user/rst/quickref.html>`_.

If you change documentation (``docs/source folder``) you can rebuild it in the container by ::

  make upload-docs

Source files of the docs are where code source lives in folder ``docs/source``. While running ``make upload-docs`` the docs source files are copied to {{ project_name }}-docs container where are compiled by Sphinx to HTML and then copied to Nginx to be served as static files.


.. toctree::
   :maxdepth: 2

