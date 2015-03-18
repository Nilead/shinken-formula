
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

  cmd.wait:
    - user: shinken
    - name: shinken --init
    - watch:
        - pip: shinken

# turn off all daemons for starters, we'll turn them on in other sls
# files
{% from 'shinken/macros.sls' import disable_daemon %}
{% for d in ['brokerd', 'pollerd', 'reactionnerd', 'receiverd', 'schedulerd'] %}
# {disable_daemon(d)}
{% endfor %}

# some states to trigger restarts

shinken-arbiter.reload:
  module.wait:
    - name: service.reload
    - m_name: shinken-arbiter
