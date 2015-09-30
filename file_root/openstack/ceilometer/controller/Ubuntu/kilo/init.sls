{% set ceilometer = salt['openstack_utils.ceilometer']() %}
{% set service_users = salt['openstack_utils.openstack_users']('service') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}
{% set rabbitmq = salt['openstack_utils.rabbitmq']() %}
{% set glance = salt['openstack_utils.glance']() %}
{% set cinder = salt['openstack_utils.cinder']() %}


ceilometer_controller_db_grant:
  mongodb_user.present:
  - name: {{ ceilometer['database']['username'] }}
  - passwd: {{ ceilometer['database']['password'] }}
  - database: {{ ceilometer['database']['db_name'] }}


ceilometer_controller_conf_keystone_authtoken:
  ini.sections_absent:
    - name: "{{ ceilometer['conf']['ceilometer'] }}"
    - sections:
        keystone_authtoken:
          - auth_host
          - auth_port
          - auth_protocol
    - require:
      - mongodb_user: ceilometer_controller_db_grant
{% for pkg in ceilometer['packages']['controller'] %}
      - pkg: ceilometer_controller_{{ pkg }}_install
{% endfor %}


ceilometer_controller_conf:
  ini.options_present:
    - name: "{{ ceilometer['conf']['ceilometer'] }}"
    - sections:
        database:
          connection: "mongodb://{{ ceilometer['database']['username'] }}:{{ ceilometer['database']['password'] }}@{{ openstack_parameters['controller_ip'] }}:27017/{{ ceilometer['database']['db_name'] }}"
        DEFAULT:
          auth_strategy: "keystone"
        keystone_authtoken: 
          auth_uri: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          identity_uri: "http://{{ openstack_parameters['controller_ip'] }}:35357"
          admin_tenant_name: service
          admin_user: ceilometer
          admin_password: "{{ service_users['ceilometer']['password'] }}"
        service_credentials:
          os_auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          os_username: ceilometer
          os_tenant_name: service
          os_password: "{{ service_users['ceilometer']['password'] }}"
          os_endpoint_type: internalURL
          os_region_name: RegionOne
        publisher:
          telemetry_secret: {{ ceilometer['metering_secret'] }}
    - require:
      - ini: ceilometer_controller_conf_keystone_authtoken


ceilometer_controller_conf_cinder:
  ini.options_present:
    - name: {{ ceilometer['conf']['ceilometer_volume'] }}
    - sections:
        DEFAULT:
          control_exchange: cinder
          notification_driver: messagingv2


ceilometer_controller_conf_image_registry:
  ini.options_present:
    - name: {{ ceilometer['conf']['ceilometer_image_registry'] }}
    - sections:
        DEFAULT:
          notification_driver: messagingv2
          rpc_backend: "rabbit"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: {{ rabbitmq['user_password'] }}


ceilometer_controller_conf_image_api:
  ini.options_present:
    - name: {{ ceilometer['conf']['ceilometer_image_api'] }}
    - sections:
        DEFAULT:
          notification_driver: messagingv2
          rpc_backend: "rabbit"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: {{ rabbitmq['user_password'] }}


ceilometer_controller_sqlite_delete:
  file.absent:
    - name: {{ ceilometer['files']['sqlite'] }}


{% for service in ceilometer['services']['controller'] %}
ceilometer_controller_{{ service }}_running:
  service.running:
    - enable: True
    - name: "{{ ceilometer['services']['controller'][service] }}"
    - watch:
      - ini: ceilometer_controller_conf
{% endfor %}


{% for service in cinder['services']['controller'] %}
ceilometer_cinder_controller_{{ service }}_running:
  service.running:
    - enable: True
    - name: {{ cinder['services']['controller'][service] }}
    - watch:
      - ini: ceilometer_controller_conf_cinder
{% endfor %}


ceilometer_glance_registry_running:
  service.running:
    - enable: True
    - name: "{{ glance['services']['registry'] }}"
    - watch:
      - ini: ceilometer_controller_conf_image_registry


ceilometer_glance_api_running:
  service.running:
    - enable: True
    - name: "{{ glance['services']['api'] }}"
    - watch:
      - ini: ceilometer_controller_conf_image_api


ceilometer_controller_wait:
  cmd:
    - run
    - name: sleep 5
    - require:
{% for service in ceilometer['services']['controller'] %}
      - service: ceilometer_controller_{{ service }}_running
{% endfor %}
{% for service in cinder['services']['controller'] %}
      - service: ceilometer_cinder_controller_{{ service }}_running
{% endfor %}
      - service: ceilometer_glance_registry_running
      - service: ceilometer_glance_api_running
