{% set ceilometer = salt['openstack_utils.ceilometer']() %}
{% set service_users = salt['openstack_utils.openstack_users']('service') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}
{% set nova = salt['openstack_utils.nova']() %}


ceilometer_compute_conf_keystone_authtoken:
  ini.sections_absent:
    - name: "{{ ceilometer['conf']['ceilometer'] }}"
    - sections:
        keystone_authtoken:
          - auth_host
          - auth_port
          - auth_protocol
    - require:
{% for pkg in ceilometer['packages']['compute'] %}
      - pkg: ceilometer_compute_{{ pkg }}_install
{% endfor %}


ceilometer_compute_conf:
  ini.options_present:
    - name: "{{ ceilometer['conf']['ceilometer'] }}"
    - sections:
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
      - ini: ceilometer_compute_conf_keystone_authtoken


ceilometer_compute_conf_nova:
  ini.options_present:
    - name: {{ ceilometer['conf']['ceilometer_compute'] }}
    - sections:
        DEFAULT:
          instance_usage_audit: True
          instance_usage_audit_period: hour
          notify_on_state_change: vm_and_task_state
          notification_driver: messagingv2
    - require:
      - ini: ceilometer_compute_conf


{% for service in ceilometer['services']['compute'] %}
ceilometer_compute_{{ service }}_running:
  service.running:
    - enable: True
    - name: "{{ ceilometer['services']['compute'][service] }}"
    - watch:
      - ini: ceilometer_compute_conf
      - ini: ceilometer_compute_conf_nova
{% endfor %}


{% for service in nova['services']['compute']['kvm'] %}
ceilometer_nova_compute_{{ service }}_running:
  service.running:
    - enable: True
    - name: {{ nova['services']['compute']['kvm'][service] }}
    - watch:
      - ini: ceilometer_compute_conf_nova
{% endfor %}


ceilometer_compute_wait:
  cmd:
    - run
    - name: sleep 5
    - require:
{% for service in ceilometer['services']['compute'] %}
      - service: ceilometer_compute_{{ service }}_running
{% endfor %}
{% for service in nova['services']['compute']['kvm'] %}
      - service: ceilometer_nova_compute_{{ service }}_running
{% endfor %}
