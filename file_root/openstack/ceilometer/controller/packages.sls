{% set ceilometer = salt['openstack_utils.ceilometer']() %}


{% for pkg in ceilometer['packages']['controller'] %}
ceilometer_controller_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
