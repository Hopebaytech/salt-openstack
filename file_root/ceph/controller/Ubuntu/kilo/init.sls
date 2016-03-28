{% set ceph = salt['pillar.get']('ceph', default=[]) %}
{% set glance = salt['openstack_utils.glance']() %}
{% set cinder = salt['openstack_utils.cinder']() %}
{% set admin_users = salt['openstack_utils.openstack_users']('admin') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}
{% set keystone = salt['openstack_utils.keystone']() %}


ceph_controller_hosts:
  host.present:
    - ip: {{ openstack_parameters['controller_ip'] }}
    - names:
      - controller


ceph_radosgw_hosts:
  host.present:
    - ip: {{ ceph['radosgw']['ip'] }}
    - names:
      - radosgw


/etc/ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - require:
{% for pkg in salt['pillar.get']('resources:ceph')['packages'] %}
      - pkg: ceph_controller_{{ pkg }}_install
{% endfor %}


ceph_conf:
  file.managed:
    - name: "/etc/ceph/ceph.conf"
    - user: root
    - group: root
    - mode: 644
    - contents: |
        {% for monaddr in ceph['monitors'] %}
        [mon.mon-{{ loop.index }}]
        host = mon-{{ loop.index }}
        mon addr = {{ monaddr }}
        {% endfor %}
    - require:
      - file: /etc/ceph


glance_ceph_keyring:
  file.managed:
    - name: "/etc/ceph/ceph.client.{{ ceph['glance']['user'] }}.keyring"
    - user: glance
    - group: glance
    - mode: 644
    - contents: |
        [client.{{ ceph['glance']['user'] }}]
            key = {{ ceph['glance']['keyring'] }}
    - require:
      - file: /etc/ceph


glance_ceph_api_conf:
  ini.options_present:
    - name: "{{ glance['conf']['api'] }}"
    - sections: 
        glance_store:
          default_store: rbd
          stores: glance.store.filesystem.Store, glance.store.rbd.Store, glance.store.http.Store
          rbd_store_pool: {{ ceph['glance']['pool'] }}
          rbd_store_user: {{ ceph['glance']['user'] }}
          rbd_store_ceph_conf: /etc/ceph/ceph.conf
          rbd_store_chunk_size: 8
        DEFAULT:
          default_store: rbd
          show_image_direct_url: True
    - require:
      - file: glance_ceph_keyring
      - cmd: glance_wait


glance_ceph_api_dead:
  service.dead:
    - enable: True
    - name: "{{ glance['services']['api'] }}"
    - require:
      - ini: glance_ceph_api_conf


glance_ceph_api_running:
  service.running:
    - enable: True
    - reload: True
    - name: "{{ glance['services']['api'] }}"
    - require:
      - service: glance_ceph_api_dead
    - watch:
      - ini: glance_ceph_api_conf


glance_ceph_wait:
  cmd.run:
    - name: sleep 5
    - require:
      - service: glance_ceph_api_running


cinder_controller_keyring:
  file.managed:
    - name: "/etc/ceph/ceph.client.{{ ceph['cinder']['user'] }}.keyring"
    - user: cinder
    - group: cinder
    - mode: 644
    - contents: |
        [client.{{ ceph['cinder']['user'] }}]
            key = {{ ceph['cinder']['keyring'] }}
    - require:
      - file: /etc/ceph


cinder_ceph_controller_conf:
  ini.options_present:
    - name: "{{ cinder['conf']['cinder'] }}"
    - sections:
        DEFAULT:
          enabled_backends: "rbd-1,rbd-2"
          default_volume_type: "disk"
          volume_usage_audit_period: "hour"
        rbd-1:
          volume_group: cinder-volumes-1
          volume_driver: cinder.volume.drivers.rbd.RBDDriver
          volume_backend_name: rbd-disk
          rbd_pool: {{ ceph['cinder']['diskpool'] }}
          rbd_ceph_conf: /etc/ceph/ceph.conf
          rbd_flatten_volume_from_snapshot: "true"
          rbd_max_clone_depth: 5
          rbd_store_chunk_size: 4
          rados_connect_timeout: -1
          glance_api_version: 2
          rbd_user: {{ ceph['cinder']['user'] }}
          rbd_secret_uuid: 457eb676-33da-42ec-9a8c-9293d545c337
        rbd-2:
          volume_group: cinder-volumes-2
          volume_driver: cinder.volume.drivers.rbd.RBDDriver
          volume_backend_name: rbd-ssd
          rbd_pool: {{ ceph['cinder']['ssdpool'] }}
          rbd_ceph_conf: /etc/ceph/ceph.conf
          rbd_flatten_volume_from_snapshot: "true"
          rbd_max_clone_depth: 5
          rbd_store_chunk_size: 4
          rados_connect_timeout: -1
          glance_api_version: 2
          rbd_user: {{ ceph['cinder']['user'] }}
          rbd_secret_uuid: 457eb676-33da-42ec-9a8c-9293d545c337
    - require:
      - file: cinder_controller_keyring
      - cmd: cinder_controller_wait
      - cmd: cinder_storage_wait


{% for service in cinder['services']['storage'] %}
cinder_ceph_storage_{{ service }}_dead:
  service.dead:
    - enable: True
    - name: {{ cinder['services']['storage'][service] }}
    - require:
      - ini: cinder_ceph_controller_conf
{% endfor %}


{% for service in cinder['services']['storage'] %}
cinder_ceph_storage_{{ service }}_running:
  service.running:
    - enable: True
    - reload: True
    - name: {{ cinder['services']['storage'][service] }}
    - require:
      - service: cinder_ceph_storage_{{ service }}_dead
    - watch:
      - ini: cinder_ceph_controller_conf
{% endfor %}


cinder_ceph_storage_wait:
  cmd.run:
    - name: sleep 5
    - require:
{% for service in cinder['services']['storage'] %}
      - service: cinder_ceph_storage_{{ service }}_running
{% endfor %}


cinder_ceph_volume_type:
  cmd.run:
    - name: "cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-delete disk; \
             cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-delete ssd; \
            cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-create disk && \
            cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-create ssd && \
            cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-key disk set volume_backend_name=rbd-disk && \
            cinder --os-volume-api-version 2 --os-username admin --os-tenant-name admin --os-password {{ admin_users['admin']['password'] }} --os-auth-url {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }} type-key ssd set volume_backend_name=rbd-ssd"
    - require:
      - cmd: cinder_ceph_storage_wait


/var/ceph/nss:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - require:
      - cmd: keystone_wait


keystone_nss_ca:
  cmd.run:
    - name: 'openssl x509 -in /etc/keystone/ssl/certs/ca.pem -pubkey | certutil -d /var/ceph/nss -A -n ca -t "TCu,Cu,Tuw"'
    - requre:
      - file: /var/ceph/nss


keystone_nss_cert:
  cmd.run:
    - name: 'openssl x509 -in /etc/keystone/ssl/certs/signing_cert.pem -pubkey | certutil -A -d /var/ceph/nss -n signing_cert -t "P,P,P"'
    - requre:
      - cmd: keystone_nss_ca

