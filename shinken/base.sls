
shinken-deps:
  pkg.installed:
    - pkgs:
      - python-pycurl
      - python-pip

shinken:
  user.present:
    - name: shinken
    - fullname: Shinken user
    - home: /var/lib/shinken

  pip.installed:
    - require:
      - pkg: shinken-deps
      - user: shinken

  service.running:
    - enable: True
    - reload: False
    - watch:
      - pip: shinken
      - ini: /etc/shinken/daemons/*

  cmd.wait:
    - user: shinken
    - name: shinken --init
    - watch:
        - pip: shinken

# turn off all daemons for starters, we'll turn them on in other sls
# files
{% from 'shinken/macros.sls' import disable_daemon %}
{% for d in ['brokerd', 'pollerd', 'reactionnerd', 'receiverd', 'schedulerd'] %}
# {diable_daemon(d)}
{% endfor %}

/etc/shinken/brokers/broker-master.cfg:
  file.replace:
    - pattern: |
        ^(\s+modules)\s*$
    - repl: |
        \1 webui,graphite
