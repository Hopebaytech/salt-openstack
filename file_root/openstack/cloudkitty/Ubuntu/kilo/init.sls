{% set cloudkitty = salt['openstack_utils.cloudkitty']() %}
{% set service_users = salt['openstack_utils.openstack_users']('service') %}
{% set rabbitmq = salt['openstack_utils.rabbitmq']() %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


cloudkitty_conf_keystone_authtoken:
  ini.sections_absent:
    - name: "{{ cloudkitty['conf']['cloudkitty'] }}"
    - sections:
      - keystone_authtoken
    - require:
{% for pkg in cloudkitty['packages'] %}
      - pkg: cloudkitty_{{ pkg }}_install
{% endfor %}


cloudkitty_log_dir:
  cmd.run:
    - name: mkdir -p /var/log/cloudkitty


cloudkitty_conf:
  ini.options_present:
    - name: "{{ cloudkitty['conf']['cloudkitty'] }}"
    - sections: 
        database: 
          connection: "mysql://{{ cloudkitty['database']['username'] }}:{{ cloudkitty['database']['password'] }}@{{ openstack_parameters['controller_ip'] }}/{{ cloudkitty['database']['db_name'] }}"
        keystone_authtoken: 
          auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          auth_plugin: "password"
          project_name: "service"
          region: "RegionOne"
          username: "cloudkitty"
          password: "{{ service_users['cloudkitty']['password'] }}"
        DEFAULT:
          debug: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          verbose: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          log_dir: "/var/log/cloudkitty"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: "{{ rabbitmq['user_password'] }}"
        auth:
          username: "cloudkitty"
          password: "{{ service_users['cloudkitty']['password'] }}"
          tenant: "service"
          region: "RegionOne"
          url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
        keystone_fetcher:
          username: "cloudkitty"
          password: "{{ service_users['cloudkitty']['password'] }}"
          tenant: "admin"
          region: "RegionOne"
          url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
        ceilometer_collector:
          username: "cloudkitty"
          password: "{{ service_users['cloudkitty']['password'] }}"
          tenant: "service"
          region: "RegionOne"
          url: "http://{{ openstack_parameters['controller_ip'] }}:5000"
        collect:
          collector: "ceilometer"
          services: "compute,image,volume,network.bw.in,network.bw.out,network.floating"
    - require:
      - ini: cloudkitty_conf_keystone_authtoken
      - cmd: cloudkitty_log_dir


cloudkitty_db_sync:
  cmd.run:
    - name: "su -s /bin/sh -c 'cloudkitty-dbsync upgrade && cloudkitty-storage-init' root"
    - require:
      - ini: cloudkitty_conf


cloudkitty_api_running:
  service.running:
    - enable: True
    - name: "{{ cloudkitty['services']['api'] }}"
    - require:
      - cmd: cloudkitty_db_sync
    - watch:
      - ini: cloudkitty_conf


cloudkitty_processor_running:
  service.running:
    - enable: True
    - name: "{{ cloudkitty['services']['processor'] }}"
    - require:
      - cmd: cloudkitty_db_sync
    - watch:
      - ini: cloudkitty_conf


cloudkitty_wait:
  cmd.run:
    - name: sleep 5
    - require:
      - service: cloudkitty_api_running
      - service: cloudkitty_processor_running