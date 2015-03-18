{% from 'shinken/macros.sls' import shinken_config, enable_module %}

{% set primary = salt['grains.filter_by']({
  'default' : {
    'auth_secret': salt['key.finger'](),
    'graphite': {
      'host': grains['fqdn'],
      'uri': 'http://' + grains['fqdn']
    },
    'scheduler_host': grains['fqdn'],
    'shared_config': None
  }
}, merge=salt['pillar.get']('shinken'), default='default') %}

include:
  - shinken.poller-deps

primary-deps:
  pkg.installed:
    - pkgs:
      - memcached

# all daemons
shinken-primary:
  grains.present:
    - value: True
  service.running:
   - name: shinken
   - enable: True
   - reload: False
   - watch:
     - pip: shinken
     - file: /etc/shinken/*

# install/enable some modules
{% for mod in ['webui', 'auth-cfg-password', 'sqlitedb', 'graphite', 'ui-graphite', 'retention-memcache', 'nsca', 'mod-collectd'] %}
{{enable_module(mod)}}
{% endfor %}

# configure the broker
{{shinken_config('brokers/broker-master.cfg', 'modules', 'webui,graphite')}}
{{shinken_config('modules/graphite.cfg', 'host', primary.graphite.host)}}


# configure the web ui
{{shinken_config('modules/webui.cfg', 'auth_secret', primary.auth_secret)}}
{{shinken_config('modules/webui.cfg', 'modules', 'auth-cfg-password,ui-graphite,SQLitedb')}}
{{shinken_config('modules/ui-graphite.cfg', 'uri', primary.graphite.uri)}}

# configure the scheduler
{{shinken_config('schedulers/scheduler-master.cfg', 'modules', 'MemcacheRetention')}}
{{shinken_config('schedulers/scheduler-master.cfg', 'address', primary.scheduler_host)}}

# configure the receiver
{{shinken_config('receivers/receiver-master.cfg', 'modules', 'nsca,Collectd')}}

# get the shared shinken config
{% if primary.shared_config %}
/etc/shinken/shared:
  file.recurse:
    - source: {{primary.shared_config}}
    - user: shinken
    - group: shinken
    - dir_mode: 755
    - file_mode: 664

/etc/shinken/shinken.cfg:
  file.append:
    - text: "cfg_dir=shared"

{% endif %}
