# install shared configuration files

{% set shared_repo = salt['pillar.get']('shinken:config_repo')%}

include:
  - shinken.base

config deps:
  pkg.installed:
    - pkgs:
      - git-core

config known-hosts:
  ssh_known_hosts.present:
    - user: shinken
    - name: {{shared_repo.host}}

config clone:
  git.latest:
    - name: {{shared_repo.uri}}
    - target: /opt/shinken-config
    - identity: {{shared_repo.ssh_id}}
    - require:
      - ssh_known_hosts: config*
  file.directory:
    - name: /opt/shinken-config
    - user: shinken
    - group: shinken
    - recurse:
      - user
      - group
    - watch:
      - git: config*
