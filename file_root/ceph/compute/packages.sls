{% set ceph = salt['pillar.get']('resources:ceph', default=[]) %}


{% for pkg in ceph['packages'] %}
ceph_compute_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}