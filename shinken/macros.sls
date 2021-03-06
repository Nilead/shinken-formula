{% macro enable_module(module) %}
shinken install {{module}}:
  cmd.run:
    - user: shinken
    - unless: shinken inventory | grep {{module}}
    - require:
        - pip: shinken
        - user: shinken
{%- endmacro %}

{% macro shinken_config(file, key, value, requiresMod=None) %}
/etc/shinken/{{file}} {{key}}:
  file.replace:
    - name: /etc/shinken/{{file}}
    - backup: False # shinken seems to read backup files?
    - pattern: |
        ^(\s+)#?{{key}}(\s.*)?$
    - repl: |
        \1{{key}} {{ value }}
    - require:
        - pip: shinken
{%- if requiresMod %}
        - cmd: shinken install {{requiresMod}}
{% endif %}
{%- endmacro %}
