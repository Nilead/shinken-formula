# install the shinken poller daemon

include:
  - shinken.poller_base

# enable services
shinken-poller:
  grains.present:
    - value: True
  service.running:
    - enable: True
    - require:
      - pip: shinken

# fix the poller init script (until
# https://github.com/naparuba/shinken/pull/1544 is released)
fix-init-script:
  file.replace:
    - name: /etc/init.d/shinken-poller
    - pattern: curdir=\$\(dirname "\$0"\)
    - repl: curdir=$(dirname $(readlink -f "$0"))
    - require:
        - pip: shinken
