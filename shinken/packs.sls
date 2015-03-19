{% from 'shinken/macros.sls' import enable_module %}
{% set packs = salt['pillar.get']('shinken:packs', {}) %}

include:
  - shinken.base

{% for key, source in packs.items() %}

{% if source %}

/opt/packs/{{key}}:
  file.recurse:
    - source: {{source}}
    - user: shinken
    - group: shinken
    - dir_mode: 755
    - file_mode: 664
    - require:
        - user: shinken
  cmd.wait:
    - name: shinken install --local /opt/packs/{{key}}
    - unless: shinken inventory | grep {{key}}
    - user: shinken
    - watch:
        - file: /opt/packs/{{key}}
{% else %}

{{enable_module(key)}}

{% endif %}
{% endfor %}
