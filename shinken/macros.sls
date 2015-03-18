{% macro disable_daemon(daemon) %}
/etc/shinken/daemons/{{daemon}}.ini:
  ini.options_present:
    - sections:
        daemon:
          daemon_enabled: 0
{%- endmacro %}

{% macro enable_daemon(daemon) %}
/etc/shinken/daemons/{{daemon}}.ini:
  ini.options_present:
    - sections:
        daemon:
          daemon_enabled: 1
{%- endmacro %}

{% macro enable_module(module) %}
shinken install {{module}}:
  cmd.run:
    - user: shinken
    - unless: shinken inventory | grep {{module}}
    - require:
        - pip: shinken
{%- endmacro %}

{% macro shinken_config(file, key, value) %}
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
{%- endmacro %}
