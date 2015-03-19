# install shared configuration files
{% from "shinken/map.jinja" import packages with context %}
{% set shared_repo = salt['pillar.get']('shinken:config_repo')%}

include:
  - shinken.base

config deps:
  pkg.installed:
    - names: {{packages.config}}

config known-hosts:
  ssh_known_hosts.present:
    - user: shinken
    - name: {{shared_repo.host}}
    - require:
      - user: shinken

config clone:
  git.latest:
    - name: {{shared_repo.uri}}
    - target: /opt/shinken-config
    - identity: {{shared_repo.ssh_id}}
    - require:
      - pkg: config deps
      - ssh_known_hosts: config*
  file.directory:
    - name: /opt/shinken-config
    - user: shinken
    - group: shinken
    - recurse:
      - user
      - group
    - require:
      - user: shinken
      - git: config*
    - watch:
      - git: config*
