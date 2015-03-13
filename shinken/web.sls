{% from 'shinken/macros.sls' import enable_daemon, enable_module %}

include:
  - shinken.base


{{enable_daemon('broker')}}
{{enable_module('webui')}}
{{enable_module('graphite')}}
{{enable_module('ui-graphite')}}
