{% from 'shinken/macros.sls' import shinken_config, enable_module %}

{% set primary = salt['grains.filter_by']({
  'default' : {
    'auth_secret': salt['key.finger'](),
    'graphite_host': grains['fqdn']
  }
}, merge=salt['pillar.get']('shinken:primary'), default='default') %}

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

# enable some modules
{% for mod in ['webui', 'auth-cfg-password', 'sqlitedb', 'graphite', 'ui-graphite', 'retention-memcache', 'nsca', 'mod-collectd'] %}
{{enable_module(mod)}}
{% endfor %}


{{shinken_config('brokers/broker-master.cfg', 'modules', 'webui,graphite')}}

{{shinken_config('modules/webui.cfg', 'auth_secret', primary.auth_secret)}}
{{shinken_config('modules/webui.cfg', 'modules', 'auth-cfg-password,ui-graphite,SQLitedb')}}

{{shinken_config('modules/graphite.cfg', 'host', primary.graphite_host)}}

{{shinken_config('modules/ui-graphite.cfg', 'uri', 'http://' + primary.graphite_host)}}
{{shinken_config('schedulers/scheduler-master.cfg', 'modules', 'MemcacheRetention')}}

{{shinken_config('receivers/receiver-master.cfg', 'modules', 'nsca,Collectd')}}
