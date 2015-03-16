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

Runs checks and reports back

* poller

Important pillar settings:

* ``shinken:poller:tags`` any poller tags
* ``shinken:poller:realm`` what realm this poller is for

Example::

  salt-call state.sls shinken.worker pillar='{"shinken":{"poller":{"realm":"w1"}}}'

``shinken.secondary``
---------------------

Configures this node as a spare for the primary
