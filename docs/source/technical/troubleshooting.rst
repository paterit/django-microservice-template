

Troubleshooting
===============

Networking problems on Ubuntu based host.
---------------------

When you will notice any network related problems (like being unable to reach internet during images building or from a built container; very slow network response within containers' network), check if in the file on host machine::

  /etc/default/docker

you have uncommented::

  DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"

If you change this don't forget to restart docker-engine servie. For Ubuntu::

  sudo service docker restart

.. toctree::
   :maxdepth: 2



