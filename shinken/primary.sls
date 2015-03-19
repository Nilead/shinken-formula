{% from 'shinken/macros.sls' import shinken_config, enable_module %}

{% set primary = salt['pillar.get']('shinken', default={
    'snmp_community': 'public'
}, merge=True) %}

{% set graphite = salt['pillar.get']('shinken:graphite', default={
    'host': grains['fqdn'],
    'uri': 'http://' + grains['fqdn']
}, merge=True) %}



include:
  - shinken.base
  - shinken.packs
  - shinken.poller
  - shinken.config

shinken-primary:
  grains.present:
    - value: True

# install/enable shinken modules
{% for mod in ['webui', 'auth-cfg-password', 'sqlitedb', 'graphite', 'ui-graphite', 'nsca', 'ws-arbiter', 'pickle-retention-file-scheduler', 'pickle-retention-file-generic'] %}
{{enable_module(mod)}}
{% endfor %}

# configure the broker
{{shinken_config('brokers/broker-master.cfg', 'modules', 'webui,graphite')}}
{{shinken_config('modules/graphite.cfg', 'host', graphite.host, 'graphite')}}

# configure the web ui
{{shinken_config('modules/webui.cfg', 'auth_secret', salt['key.finger'](), 'webui')}}
{{shinken_config('modules/webui.cfg', 'modules', 'auth-cfg-password,ui-graphite,SQLitedb', 'webui')}}
{{shinken_config('modules/ui-graphite.cfg', 'uri', graphite.uri, 'ui-graphite')}}

# configure the receiver
{{shinken_config('receivers/receiver-master.cfg', 'modules', 'nsca,ws-arbiter')}}

# configure the scheduler
{{shinken_config('schedulers/scheduler-master.cfg', 'modules', 'pickle-retention-file')}}
{{shinken_config('schedulers/scheduler-master.cfg', 'address', grains['fqdn'])}}

# reference the shared shinken config
/etc/shinken/shinken.cfg:
  file.append:
    - text: "cfg_dir=/opt/shinken-config"
    - require:
        - pip: shinken
        - git: config*

# fill in other defaults
/etc/shinken/resource.d/snmp.cfg:
  file.replace:
    - pattern: |
        ^\$SNMPCOMMUNITYREAD\$=.*
    - repl: |
        $SNMPCOMMUNITYREAD$={{primary.snmp_community}}
    - require:
      - pip: shinken


# write out config for extra pollers
/etc/shinken/pollers/salt-pollers.cfg:
  file.managed:
    - source: salt://shinken/files/poller.cfg
    - template: jinja
    - mode: 444
    - defaults:
        tags: 'None'
        realm: 'All'
    - require:
        - pip: shinken

# enable daemons
{% for service in ['arbiter', 'broker', 'reactionner', 'receiver', 'scheduler'] %}

shinken-{{service}} service:
  service.running:
    - name: shinken-{{service}}
    - enable: True
    - require:
      - pip: shinken

{% endfor %}

# restart the arbiter when config changes, it will distribute the rest
restart arbiter:
  module.wait:
    - name: service.restart
    - m_name: shinken-arbiter
    - require:
        - service: shinken-arbiter service
    - watch:
        - file: /etc/shinken/*
        - git: config*
