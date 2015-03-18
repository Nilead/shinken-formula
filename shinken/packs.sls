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
  cmd.wait:
    - name: shinken install --local /opt/packs/{{key}}
    - user: shinken
    - watch:
        - file: /opt/packs/{{key}}
    - watch_in:
        - module: shinken-arbiter.reload
{% else %}

{{enable_module(key)}}

{% endif %}
{% endfor %}