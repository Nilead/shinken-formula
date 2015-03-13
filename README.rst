salt-formula-shinken
====================

Formula to set up and configure Shinken_ on Debian-based systems

.. _Shinken: http://shinken-monitoring.org/

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.


Available states
================

.. contents::
   :local:

``shinken.primary``
-------------------

Configures this node as the primary shinken node.

* arbiter
* web
* broker
* reactionner
* receiver

``shinken.worker``
------------------

Runs checks and reports back to the primary

* poller
* scheduler


``shinken.secondary``
---------------------

Configures this node as a spare for the primary
