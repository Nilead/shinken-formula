{% from 'shinken/macros.sls' import enable_module %}
{% set primary = salt['grains.filter_by']({
  'default' : {
    'snmp_community': 'public'
  }
}, merge=salt['pillar.get']('shinken'), default='default') %}

include:
  - shinken.base

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
  file.symlink:
    - target: /usr/lib/nagios/plugins/utils.pm
    - require:
      - pkg: poller-deps



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


{% for mod in ['cisco', 'router', 'linux-snmp', 'switch'] %}
{{enable_module(mod)}}
{% endfor %}

/etc/shinken/resource.d/snmp.cfg:
  file.replace:
    - pattern: |
        ^\$SNMPCOMMUNITYREAD\$=.*
    - repl: |
        $SNMPCOMMUNITYREAD$={{primary.snmp_community}}
