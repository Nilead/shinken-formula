{% set poller = salt['grains.filter_by']({
  'default' : {
    'tags': 'None',
    'realm': 'All'
  }
}, merge=salt['pillar.get']('shinken:poller'), default='default') %}


include:
  - shinken.base

# just pollerd

shinken-poller:
  service.running:
    - enable: True
    - watch:
        - pip: shinken
        - file: /etc/shinken/pollers/*

/etc/shinken/pollers/poller-master.cfg tags:
  file.replace:
    - name: /etc/shinken/pollers/poller-master.cfg
    - pattern: |
        ^(\s+)#poller_tags\s.*$
    - repl: |
        \1 poller_tags {{poller.tags}}

/etc/shinken/pollers/poller-master.cfg realm:
  file.replace:
    - name: /etc/shinken/pollers/poller-master.cfg
    - pattern: |
        ^(\s+realm)\s.*$
    - repl: |
        \1 {{poller.realm}}
