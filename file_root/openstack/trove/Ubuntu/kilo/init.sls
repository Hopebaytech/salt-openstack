{% set trove = salt['openstack_utils.trove']() %}
{% set service_users = salt['openstack_utils.openstack_users']('service') %}
{% set rabbitmq = salt['openstack_utils.rabbitmq']() %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}



trove_conf_keystone_authtoken:
  ini.sections_absent:
    - name: "{{ trove['conf']['trove'] }}"
    - sections:
      - keystone_authtoken
    - require:
{% for pkg in trove['packages'] %}
      - pkg: trove_{{ pkg }}_install
{% endfor %}


trove_conf:
  ini.options_present:
    - name: "{{ trove['conf']['trove'] }}"
    - sections: 
        database: 
          connection: "mysql://{{ trove['database']['username'] }}:{{ trove['database']['password'] }}@{{ openstack_parameters['controller_ip'] }}/{{ trove['database']['db_name'] }}"
        keystone_authtoken:
          admin_password: "{{ service_users['trove']['password'] }}"
          admin_tenant_name: "service"
          admin_user: "trove"
          identity_uri: "http://{{ openstack_parameters['controller_ip'] }}:35357/"
        DEFAULT:
          debug: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          verbose: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          rpc_backend: "rabbit"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: "{{ rabbitmq['user_password'] }}"
          trove_auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          nova_compute_url: "http://{{ openstack_parameters['controller_ip'] }}:8774/v2"
          os_region_name: "RegionOne"
          cinder_service_type: "volumev2"
          swift_service_type: "object-store"
          heat_service_type: "orchestration"
          neutron_service_type: "network"
          network_label_regex: ".*"
          network_driver: "trove.network.neutron.NeutronDriver"
          ignore_dbs: "lost+found, mysql, information_schema, #mysql50#lost+found, performance_schema"
    - require:
      - ini: trove_conf_keystone_authtoken


trove_conductor_conf_remove_options:
  ini.options_absent:
    - name: "{{ trove['conf']['trove_conductor'] }}"
    - sections: 
        DEFAULT:
          - connection
    - require:
{% for pkg in trove['packages'] %}
      - pkg: trove_{{ pkg }}_install
{% endfor %}

trove_conductor_conf:
  ini.options_present:
    - name: "{{ trove['conf']['trove_conductor'] }}"
    - sections: 
        database: 
          connection: "mysql://{{ trove['database']['username'] }}:{{ trove['database']['password'] }}@{{ openstack_parameters['controller_ip'] }}/{{ trove['database']['db_name'] }}"
        DEFAULT:
          debug: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          verbose: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          trove_auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          rpc_backend: "rabbit"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: "{{ rabbitmq['user_password'] }}"
    - require:
      - ini: trove_conductor_conf_remove_options


trove_taskmanager_conf:
  ini.options_present:
    - name: "{{ trove['conf']['trove_taskmanager'] }}"
    - sections: 
        database: 
          connection: "mysql://{{ trove['database']['username'] }}:{{ trove['database']['password'] }}@{{ openstack_parameters['controller_ip'] }}/{{ trove['database']['db_name'] }}"
          guest_info: "guest_info.conf"
          injected_config_location: "/etc/trove/conf.d"
          cloudinit_location: "/etc/trove/cloudinit"
        DEFAULT:
          debug: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          verbose: "{{ salt['openstack_utils.boolean_value'](openstack_parameters['debug_mode']) }}"
          rpc_backend: "rabbit"
          rabbit_host: "{{ openstack_parameters['controller_ip'] }}"
          rabbit_userid: "{{ rabbitmq['user_name'] }}"
          rabbit_password: "{{ rabbitmq['user_password'] }}"
          trove_auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
          nova_compute_url: "http://{{ openstack_parameters['controller_ip'] }}:8774/v2"
          os_region_name: "RegionOne"
          cinder_service_type: "volumev2"
          swift_service_type: "object-store"
          heat_service_type: "orchestration"
          neutron_service_type: "network"
          use_nova_server_config_drive: "True"
          nova_proxy_admin_user: "nova"
          nova_proxy_admin_pass: "{{ service_users['nova']['password'] }}"
          nova_proxy_admin_tenant_name: "service"
          network_driver: "trove.network.neutron.NeutronDriver"
          network_label_regex: ".*"
    - require:
      - ini: trove_conf_keystone_authtoken


trove_taskmanager_upstart_patch:
  file.replace:
    - name: "/etc/init/trove-taskmanager.conf"
    - pattern: "trove.conf"
    - repl: "trove-taskmanager.conf"
    - require:
{% for pkg in trove['packages'] %}
      - pkg: trove_{{ pkg }}_install
{% endfor %}
      - ini: trove_taskmanager_conf


trove_conductor_upstart_patch:
  file.replace:
    - name: "/etc/init/trove-conductor.conf"
    - pattern: "trove.conf"
    - repl: "trove-conductor.conf"
    - require:
{% for pkg in trove['packages'] %}
      - pkg: trove_{{ pkg }}_install
{% endfor %}
      - ini: trove_conductor_conf


trove_db_sync:
  cmd.run:
    - name: "su -s /bin/sh -c 'trove-manage db_sync' trove"
    - require:
      - ini: trove_conf
      - ini: trove_conductor_conf
      - ini: trove_taskmanager_conf


trove_sqlite_delete:
  file.absent:
    - name: "{{ trove['files']['sqlite'] }}"
    - require: 
      - cmd: trove_db_sync


trove_api_running:
  service.running:
    - enable: True
    - name: "{{ trove['services']['trove_api'] }}"
    - require:
      - cmd: trove_db_sync
    - watch:
      - ini: trove_conf


trove_conductor_running:
  service.running:
    - enable: True
    - name: "{{ trove['services']['trove_conductor'] }}"
    - require:
      - cmd: trove_db_sync
    - watch:
      - ini: trove_conductor_conf


trove_taskmanager_running:
  service.running:
    - enable: True
    - name: "{{ trove['services']['trove_taskmanager'] }}"
    - require:
      - cmd: trove_db_sync
    - watch:
      - ini: trove_taskmanager_conf


trove_db_flavor:
  module.run:
  - name: nova.flavor_create
  - m_name: 'db.small'
  - ram: 1024
  - disk: 8
  - vcpus: 2
  - flavor_id: 100
  - require:
    - service: trove_api_running


trove_mysql_cloud_init:
  file.managed:
    - name: {{ trove['cloudinit']['mysql'] }}
    - user: root
    - group: root
    - mode: 644
    - contents: |
        #cloud-config

        password: t2a5l6oUd
        chpasswd: { expire: False }
        ssh_pwauth: True
        manage_etc_hosts: localhost

        bootcmd:
         - echo {{ openstack_parameters['controller_ip'] }} controller >> /etc/hosts
         - sed -i 's/HB_RABBIT_ID/{{ rabbitmq['user_name'] }}/' /etc/trove/trove-guestagent.conf
         - sed -i 's/HB_RABBIT_PASSWD/{{ rabbitmq['user_password'] }}/' /etc/trove/trove-guestagent.conf
         - touch /etc/trove/conf.d/guest_info.conf
         - chmod -R +r /etc/trove/conf.d
        # - service trove-guestagent restart

        ca-certs:
          trusted:
          - |
           -----BEGIN CERTIFICATE-----
           MIIDpzCCAo+gAwIBAgIJAKB2SL9zP7TlMA0GCSqGSIb3DQEBCwUAMGoxCzAJBgNV
           BAYTAlRXMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
           aWRnaXRzIFB0eSBMdGQxIzAhBgNVBAMMGmtoLXJhZG9zZ3cuaG9wZWJheXRlY2gu
           Y29tMB4XDTE1MDIwMzE1MDg1NVoXDTE2MDIwMzE1MDg1NVowajELMAkGA1UEBhMC
           VFcxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdp
           dHMgUHR5IEx0ZDEjMCEGA1UEAwwaa2gtcmFkb3Nndy5ob3BlYmF5dGVjaC5jb20w
           ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDF4BvgpAFR07HIn4z8mJ9d
           KiRHoECBXltYkA0eBpw5K9EWCNORoiyG6yLst+IPR9hh25ABXs8e82KUbE5qAZ5w
           2rkPCSf1QcWV0xsyXrtMSB8VgX8n5Q9O70S865/zJpD+Gs96jJzHeC1PCc/prq+D
           iYdBwoYpDYJ+Fn44+VT+YE+yt6dGV1eyJWNJ7bL1xQFV2xehrfxmCKbAY+x2n9m/
           EbzgW6THhL7k3we2+M+pc5ESTlmyE41D/9lE8JzGKtMJhA2Ww/QS6CPtNOIzHjBM
           J2KxM1IsOggrIdPHfoQZaZcqOrNlXFzvs3D9uLFutvMQqipJ9Ngu0imGA7YVDlrF
           AgMBAAGjUDBOMB0GA1UdDgQWBBQQHB/jeUSQ7RHx9fJHDKVKSkwWwjAfBgNVHSME
           GDAWgBQQHB/jeUSQ7RHx9fJHDKVKSkwWwjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3
           DQEBCwUAA4IBAQCiPfC9XXHP5sGYRvsLIEUXDJoaU//UD69bolWSTWlcr02rgEd7
           EIhvx/3RCV63CTyVDFqeMTy3iy5X1CPBiomAR4vfZPZtkxhVl2v6XN1rjvMzpYXC
           gnHLDD6De5A6D8A3xtNTyY/wosPlMb8a628C9zLLriPe2H4ezm1a3oFT+ALfHfJr
           0UjSE223Ss329vB/RX+n2ofsV2nrN/jEiJbltl9BvhdrX8NCdy9wzcEYC6EWqOBj
           pBSO/SxSJ2l8HSgrhFAZa1S1ELghP0IhAMynEXdGW17lYVBduCyifCa03U6lG0lQ
           cl3oKUAkZRJuZdXXZlFA1mCs1fRWaSvWXLPE
           -----END CERTIFICATE-----
    - require:
      - service: trove_api_running


