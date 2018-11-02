

Some use cases for developing dmt
=================================

Adding new make commands as a new task in Buildbot builder
**********************************************************

- add new command into ``Makefile`` in the main folder

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

Now when you force in Buildbot web console to run Full rebuid builder the new task will be fired.

.. toctree::
   :maxdepth: 2



