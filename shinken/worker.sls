{% from 'shinken/macros.sls' import shinken_config %}
{% set poller = salt['grains.filter_by']({
  'default' : {
    'tags': 'None',
    'realm': 'All'
  }
}, merge=salt['pillar.get']('shinken:poller'), default='default') %}


include:
  - shinken.poller-deps


shinken-worker:
  grains.present:
    - value: True
  # just pollerd
  service.running:
    - name: shinken-poller
    - enable: True
    - watch:
        - pip: shinken
        - file: /etc/shinken/pollers/*

{{shinken_config('pollers/poller-master.cfg', 'poller_tags', poller.tags)}}
{{shinken_config('pollers/poller-master.cfg', 'realm', poller.realm)}}
