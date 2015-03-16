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

{% for mod in ['cisco', 'router', 'linux-snmp', 'switch'] %}
{{enable_module(mod)}}
{% endfor %}

/etc/shinken/resource.d/snmp.cfg:
  file.replace:
    - pattern: |
        ^\$SNMPCOMMUNITYREAD\$=.*
    - repl: |
        $SNMPCOMMUNITYREAD$={{primary.snmp_community}}
