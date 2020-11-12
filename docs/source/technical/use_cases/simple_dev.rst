
Simple development use cases
============================

.. contents::
   :depth: 1
   :local:

Locating problem with build on docker-machine (via buildbot)
************************************************************

- go to buildbot console (localhost:8010)
- take a look which part failed
- go to your project dir (eg. dmt-testing/yourservice)
- set env variables for DOCKER

.. code-block:: bash

  set -a
  . ./docker-machinve.docker.env
  set +a

- now you can use make commands like ``make logs-web`` to see logs for web container
- when you are done, don't forget to unset DOCKER envs, by

.. code-block:: bash

  eval $(make unset-docker)

Adding new sbe test
*******************

- add new example.feature file in ``testing/features`` folder

- run ``make sbe`` and grab proposed code snippets into ``testing/features/steps/example.py``

- rework the code and the test until ``make sbe`` produce only green output


Adding new make commands as a new task in Buildbot builder
**********************************************************

- add a new command into ``Makefile`` in the main folder

.. code-block:: bash
  :linenos:

  prune-docker:
    docker container stop $(docker container ls -a -q)
    docker system prune --all --force --volumes

- in the ``cicd/master/config/master.cfg`` add

.. code-block:: python
  :linenos:
  
  prune_docker = steps.ShellCommand(name="prune docker",
                                  command=["make", "prune-docker"])
  ...
  full_build_factory.addStep(make_prune_docker)

- run make command to upload Buildbot config file and reload it

.. code-block:: bash
  :linenos:

  make cicd-upload

Verify if at the end of the output you can find ``Config file is good!``

To make changes in Makefile effective in ``CICD`` context we need to rebuild cicd-worker where those commands are run.

.. code-block:: bash
    :linenos:

    make clean-cicd
    source ../virtenv/bin/activate #not needed if already docker-compose is available
    make run-cicd

Now when you force in Buildbot web console to run Full rebuild builder the new task will be fired.

