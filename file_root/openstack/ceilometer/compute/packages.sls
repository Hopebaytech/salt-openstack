{% set ceilometer = salt['openstack_utils.ceilometer']() %}


{% for pkg in ceilometer['packages']['compute'] %}
ceilometer_compute_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
