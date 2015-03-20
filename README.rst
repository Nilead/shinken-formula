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
    windows:


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
``pollers`` key in the ``pillar.example``.

* arbiter
* broker

  * port: 7767 - website w/ graphite support

* reactionner
* receiver

  * port 5667 - nsca_ with xor encryption
  * port 7760 - `ws_arbiter`_ for submitting external commands

* scheduler

  * configured for the default "All" realm

* poller

  * configured for the default "All" realm and untagged hosts

.. _nsca: http://exchange.nagios.org/directory/Addons/Passive-Checks/NSCA--2D-Nagios-Service-Check-Acceptor/details
.. _ws_arbiter: https://github.com/shinken-monitoring/mod-ws-arbiter

``shinken.poller``
------------------

Nodes that runs checks and reports back to the primary. Listens for
instructions from other daemons on port 7771.


TODO ``shinken.secondary``
--------------------------

Configures this node as a spare daemons for the primary
