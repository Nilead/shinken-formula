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
    - unless: test -d /var/lib/shinken/modules/{{module}}
{%- endmacro %}
