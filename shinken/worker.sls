{% from 'shinken/macros.sls' import shinken_config, enable_module %}

{% set worker = salt['pillar.get']('shinken:worker',
  default={'snmp_community': 'public'},
  merge=True) %}

include:
  - shinken.base
  - shinken.packs

poller-deps:
  pkg.installed:
    - pkgs:
        - nagios-plugins
        - libnet-snmp-perl
        - snmp
        - snmp-mibs-downloader

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

/etc/shinken/resource.d/snmp.cfg:
  file.replace:
    - pattern: |
        ^\$SNMPCOMMUNITYREAD\$=.*
    - repl: |
        $SNMPCOMMUNITYREAD$={{worker.snmp_community}}
    - require:
      - pip: shinken

shinken-worker:
  grains.present:
    - value: True

{{enable_module('pickle-retention-file-generic')}}
{{enable_module('pickle-retention-file-scheduler')}}

# enable services
{% for service in ['scheduler', 'poller'] %}

shinken service - {{service}}:
  service.running:
    - name: shinken-{{service}}
    - enable: True
    - watch:
      - pip: shinken
      - file: /etc/shinken/*

{% endfor %}
