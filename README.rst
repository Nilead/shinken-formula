salt-formula-shinken
====================

Formula to set up and configure Shinken_ on Debian-based systems

.. _Shinken: http://shinken-monitoring.org/

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Installing additional packs
---------------------------

Shinken_ uses packs_ to distribute checks and config. Use pillar
``shinken:packs`` to specify what additional packs to install. A few
are installed by default. You want to set this up for the shinken
primary, and any workers. packs_ often install the check programs
(e.g. ``check_wmi``) that need to be installed on the worker nodes.

Example::

  packs:
    # copy the pack to the minion
    my-pack: salt://my-custom-pack
    # if the source is missing then pull from shinken.io
    pack-windows:


.. _packs: http://shinken.readthedocs.org/en/latest/14_contributing/create-and-push-packs.html

Syncronizing config
-------------------

The configuration about what hosts / services to monitor need to be
shared between all arbiters. This formula depends on you sharing this
via a git repository. You specify the git information via pillars.

Available states
================

.. contents::
   :local:

``shinken.primary``
-------------------

Configures this node as the primary Shinken_ node. Shinken_ requires
that the master node has configuration about all daemons. See the
``workers`` key in the ``pillar.example``.

* arbiter
* broker
  * port: 7767 - website w/ graphite support
* reactionner
* receiver
  * port 5667 - nsca_ with xor encryption
  * port 7760 - `ws_arbiter`_ for submitting external commands
* scheduler
  * retains status in memcached

Important pillar settings:

* ``shinken:graphite:host`` host name for sending metrics in
* ``shinken:graphite:uri`` uri for rendering graphs in the shinken ui
* ``shinken:config_repo:host`` git server
* ``shinken:config_repo:uri`` git clone URI
* ``shinken:config_repo:ssh_id`` ssh identity to use
* ``shinken:workers`` data about the the worker nodes, used to
  generate shinken config

.. _nsca: http://exchange.nagios.org/directory/Addons/Passive-Checks/NSCA--2D-Nagios-Service-Check-Acceptor/details
.. _ws_arbiter: https://github.com/shinken-monitoring/mod-ws-arbiter

``shinken.worker``
------------------

Runs checks and reports back.

* poller
* scheduler

Important pillar settings:

* ``shinken:worker:snmp_community`` default snmp community for checks
* ``shinken:packs`` what extra packs to install


TODO ``shinken.secondary``
--------------------------

Configures this node as a spare for the primary
