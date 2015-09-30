{% set mongodb = salt['openstack_utils.mongodb']() %}


{% for pkg in mongodb['packages'] %}
mongodb_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}


mongodb_service_dead:
  service.dead:
    - name: {{ mongodb['services']['mongodb'] }}


mongodb_conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - name: {{ mongodb['conf']['mongod'] }}
    - contents: |
        dbpath=/var/lib/mongodb
        logpath=/var/log/mongodb/mongodb.log
        logappend=true
        bind_ip = 0.0.0.0
        journal=true
    - require: 
{% for pkg in mongodb['packages'] %}
      - pkg: mongodb_{{ pkg }}_install
{% endfor %}


mongodb_service_running:
  service.running:
    - enable: True
    - name: {{ mongodb['services']['mongodb'] }}
    - watch: 
      - file: mongodb_conf