{% set trove = salt['openstack_utils.trove']() %}


{% for pkg in trove['packages'] %}
trove_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}