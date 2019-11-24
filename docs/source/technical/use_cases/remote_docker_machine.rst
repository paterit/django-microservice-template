

Set up Remote Docker Machine
============================

.. contents:: Table of Contents
   :depth: 1
   :local:


Create Remote Docker Machine (RDM) ready for secure connections
---------------------------------------------------------------

As an example we will use different Ubunut server available in the same local network, but this solution should work for any machine that can be reach with its IP address.
First of all we need to verify if docker machinie is ready to accept encrypted connections. If this is a fresh Ubuntu instalation make sure that `this post-installation steps for Linux <https://docs.docker.com/install/linux/linux-postinstall/#configuring-remote-access-with-systemd-unit-file>`_ are done. 

To make the host available from any machine in your network in the file ``/lib/systemd/system/docker.service`` instead of ``-H tcp://127.0.0.1:2375`` put ``-H tcp://0.0.0.0:2375``.


Prepare certificates on you RDM
-------------------------------


Copy certificates from your RDM to your CI/CD worker /cert folder
-----------------------------------------------------------------


Test if RDM works
-----------------





