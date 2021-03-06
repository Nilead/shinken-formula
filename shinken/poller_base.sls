# install the shinken poller dependendies
{% from "shinken/map.jinja" import packages with context %}

include:
  - shinken.base
  - shinken.packs

poller-deps:
  pkg.installed:
    - names: {{packages.poller}}

/usr/lib/nagios/plugins/check_icmp:
  file.managed:
    - user: root
    - group: root
    - mode: 4555
    - require:
      - pkg: poller-deps

# https://github.com/shinken-monitoring/pack-linux-snmp/issues/10
/var/lib/shinken/libexec/utils.pm:
  file.copy:
    - source: /usr/lib/nagios/plugins/utils.pm
    - user: shinken
    - group: shinken
    - require:
      - pkg: poller-deps
      - user: shinken
      - pip: shinken

# TODO: dedupe between here and cacti-formula
snmp-configuration:
  # enable third-party MIBs
  file.replace:
    - name: /etc/snmp/snmp.conf
    - pattern: '^mibs'
    - repl: '#mibs'
    - watch:
      - pkg: poller-deps

  # download third-party MIBs
  cmd.wait:
    - name: download-mibs
    - watch:
      - pkg: poller-deps
