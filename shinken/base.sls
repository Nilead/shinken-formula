{% from "shinken/map.jinja" import packages with context %}

shinken-deps:
  pkg.installed:
    - names: {{packages.shinken}}

shinken:
  user.present:
    - name: shinken
    - fullname: Shinken user
    - home: /var/lib/shinken

  pip.installed:
    - name: shinken
    - require:
      - pkg: shinken-deps
      - user: shinken

  cmd.run:
    - user: shinken
    - name: shinken --init
    - require:
        - pip: shinken
        - user: shinken
