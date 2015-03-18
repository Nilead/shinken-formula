{% from 'shinken/macros.sls' import shinken_config %}

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
