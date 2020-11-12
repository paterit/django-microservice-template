

Set up Remote Docker Machine
============================

.. contents:: Table of Contents
   :depth: 1
   :local:


Create Remote Docker Machine (RDM) ready for secure connections
---------------------------------------------------------------

As an example we will use different than your workstation Ubuntu server available in the same local network, but this solution 
should work for any machine that can be reach with its IP address.
First of all we need to verify if docker machine is ready to accept encrypted http connections. 
If this is a fresh Ubuntu installation make sure 
that `this post-installation steps for Linux <https://docs.docker.com/install/linux/linux-postinstall/#configuring-remote-access-with-systemd-unit-file>`_ are done. 

To make the host available from any machine in your network in the file ``/lib/systemd/system/docker.service`` instead of ``-H tcp://127.0.0.1:2375`` put ``-H tcp://0.0.0.0:2375``.

Flush changes and restart docker:

.. code-block:: bash

    sudo systemctl daemon-reload
    sudo systemctl restart docker

To test if your RDM is open to http connections (not encrypted yet), on your workstation in the new terminal window run:

.. code-block:: bash
    
    # This will show your local containers
    docker images
    # export DOCKER_HOST=your.remote.docker.IP
    # in my case it would be
    export DOCKER_HOST=192.168.100.34
    # Now as we are in the context of remoted DOCKER_HOST, running
    docker images
    # will show an empty list if your Ubuntu server is brand new or some other list if the server was already used for docker


Prepare certificates on you RDM
-------------------------------

Follow `the instruction <https://docs.docker.com/engine/security/https/>`_ to generate your certificates.

You can also use `certs generator <https://github.com/paterit/ssl-server-client>`_ - take a look at ``make help`` output there.


Configure your docker daemon on RDM to accept only secure http connections
--------------------------------------------------------------------------

Next step is to configure yur docker host to accept only secure http connections. Following `this doc <https://docs.docker.com/engine/security/https/>`_ 
and using certificates generated in previous step, in the config file ``/lib/systemd/system/docker.service`` 
add to ``ExecStart`` command parameters ``--tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem`` 
and make sure that path to the cert files are correct.

Flush changes and restart docker:

.. code-block:: bash

    sudo systemctl daemon-reload
    sudo systemctl restart docke

On your docker client machine run this code to verify the secure connetion:

.. code-block:: bash
  
  # set env variables that will tell docker to use secure connection and your certificates 
  # use IP or host name valid for your case
  export DOCKER_HOST=192.168.100.34:2375
  export DOCKER_TLS_VERIFY=1
  export DOCKER_CERT_PATH=/path/to/previously/generated/certs
  # now docker should run in the context of your RDM
  docker version
  docker ps


Copy certificates from your RDM to your CI/CD worker /cert folder
-----------------------------------------------------------------

CI/CD worker acts as a docker client for your RDM so copy your ca.pem, key.pem and cert.pem to ``cicd/worker/certs`` in your DMT project folder. Set the right values in ``remote.docker.env`` file:

.. code-block:: text
 
  # use your RDM IP address, in my case it is 192.168.100.34
  DOCKER_HOST=192.168.100.34:2375
  DOCKER_TLS_VERIFY=1
  # this is the location where files from ``cicd/worker/certs`` will be copied. no need to change that
  DOCKER_CERT_PATH=//buildbot/certs


Test if RDM works
-----------------

Go to ``dmt-testing`` directory and run:

.. code-block:: text

  make test-remote

During the test procedure variable defined in ``remote.docker.env`` file will be copied into ``cicd/cicd.docker.env`` file which is used by CI/CD worker to determine docker machine
on which DMT will be installed and tested (trough ``env_file`` setting for ``cicd-worker`` service definition in docker-compose.cicd.yml).




