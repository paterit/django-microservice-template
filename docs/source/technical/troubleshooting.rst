

Troubleshooting
===============

Networking problems on Ubuntu-based hosts.
------------------------------------------

When you will notice any network-related problems (like being unable to reach the internet during images building or from a built container; very slow network response within containers' network), check if in the file on the host machine::

  /etc/default/docker

you have uncommented::

  DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"

If you change this don't forget to restart the docker-engine service. For Ubuntu::

  sudo service docker restart

.. toctree::
   :maxdepth: 2



