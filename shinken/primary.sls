{% from 'shinken/macros.sls' import shinken_config, enable_module %}

{% set primary = salt['pillar.get']('shinken', default={
    'auth_secret': salt['key.finger'](),
    'scheduler_host': grains['fqdn'],
}, merge=True) %}

{% set graphite = salt['pillar.get']('shinken:graphite', default={
    'host': grains['fqdn'],
    'uri': 'http://' + grains['fqdn']
}, merge=True) %}



include:
  - shinken.base
  - shinken.config

primary-deps:
  pkg.installed:
    - pkgs:
      - memcached
  grains.present:
    - name: shinken-primary
    - value: True

# all daemons
{% for service in ['arbiter', 'broker', 'reactionner', 'receiver'] %}

shinken service - {{service}}:
  service.running:
    - name: shinken-{{service}}
    - enable: True
    - watch:
      - pip: shinken
      - file: /etc/shinken/*

{% endfor %}

# install/enable some modules
{% for mod in ['webui', 'auth-cfg-password', 'sqlitedb', 'graphite', 'ui-graphite', 'nsca', 'ws-arbiter'] %}
{{enable_module(mod)}}
{% endfor %}

# configure the broker
{{shinken_config('brokers/broker-master.cfg', 'modules', 'webui,graphite')}}
{{shinken_config('modules/graphite.cfg', 'host', graphite.host)}}


# configure the web ui
{{shinken_config('modules/webui.cfg', 'auth_secret', primary.auth_secret)}}
{{shinken_config('modules/webui.cfg', 'modules', 'auth-cfg-password,ui-graphite,SQLitedb')}}
{{shinken_config('modules/ui-graphite.cfg', 'uri', graphite.uri)}}


# configure the receiver
{{shinken_config('receivers/receiver-master.cfg', 'modules', 'nsca,ws-arbiter')}}

# remove some defaults
/etc/shinken/pollers/poller-master.cfg:
  file.absent:
    - require:
        - pip: shinken
/etc/shinken/schedulers/scheduler-master.cfg:
  file.absent:
    - require:
        - pip: shinken

# get the shared shinken config
/etc/shinken/shinken.cfg:
  file.append:
    - text: "cfg_dir=/opt/shinken-config"

# write out config for workers

{% set workers = salt['pillar.get']('shinken:workers', {}) %}

{% for host, conf in workers.items() %}

/etc/shinken/pollers/{{host}}.cfg:
  file.managed:
    - source: salt://shinken/files/poller.cfg
    - template: jinja
    - mode: 444
    - defaults:
        host: {{host}}
        tags: 'None'
        realm: ''
{% if conf %}
    - context:
{% for key, value in conf.iteritems() %}
        {{ key }}: {{ value }}
{% endfor %}
{% endif %}

/etc/shinken/schedulers/{{host}}.cfg:
  file.managed:
    - source: salt://shinken/files/scheduler.cfg
    - template: jinja
    - mode: 444
    - defaults:
        host: {{host}}
        realm: 'All'
{% if conf %}
    - context:
{% for key, value in conf.iteritems() %}
        {{ key }}: {{ value }}
{% endfor %}
{% endif %}

{% endfor %}
