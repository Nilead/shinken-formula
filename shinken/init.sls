
python-pip:
  pkg.installed

shinken-deps:
  pkg.installed:
    - pkgs:
      - python-pycurl
      - python-setuptools
      - python-sqlite

shinken:
  user.present:
    - name: shinken
    - fullname: Shinken user
    - home: /var/lib/shinken

  pip.installed:
    - require:
      - pkg: python-pip
      - pkg: shinken-deps
      - user: shinken

  service:
    - running
    - enable: True
    - reload: False
    - watch:
      - pip: shinken
      - pkg: shinken-deps

/var/lib/shinken/.shinken.ini:
  file.managed:
    - source: salt://shinken/files/dotshinken.ini
    - user: shinken
    - group: shinken
    - require:
      - user: shinken

########################################
# Modules support
########################################
shinken install booster-nrpe:
  cmd.run:
    - user: shinken
    - unless: test -d /var/lib/shinken/modules/booster-nrpe
    - require:
      - pip: shinken

shinken install auth-cfg-password:
  cmd.run:
    - user: shinken
    - unless: test -d /var/lib/shinken/modules/auth-cfg-password
    - require:
      - pip: shinken
shinken install sqlitedb:
  cmd.run:
    - user: shinken
    - unless: test -d /var/lib/shinken/modules/sqlitedb
    - require:
      - pip: shinken
/etc/shinken/modules/sqlitedb.cfg:
  file.managed:
    - source: salt://shinken/files/sqlitedb.cfg
    - template: jinja
    - require:
      - cmd: shinken install sqlitedb
    - watch_in:
      - service: shinken
shinken install webui:
  cmd.run:
    - user: shinken
    - unless: test -d /var/lib/shinken/modules/webui
    - require:
      - pip: shinken
/etc/shinken/modules/webui.cfg:
  file.managed:
    - source: salt://shinken/files/webui.cfg
    - template: jinja
    - require:
      - cmd: shinken install sqlitedb
    - watch_in:
      - service: shinken


/etc/shinken/brokers/broker-master.cfg:
  file.managed:
    - source: salt://shinken/files/broker-master.cfg
    - watch_in:
      - service: shinken


########################################
# User info
########################################
{% for contact, contact_info in salt['pillar.get']('shinken:users', {}).items() %}
/etc/shinken/contacts/{{ contact }}.cfg:
  file.managed:
    - source: salt://shinken/files/contact.cfg
    - template: jinja
    - user: shinken
    - context:
        contact: {{ contact }}
        contact_info: {{ contact_info }}
    - watch_in:
      - service: shinken
{% endfor %}


