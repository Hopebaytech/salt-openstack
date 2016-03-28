{% set admin_users = salt['openstack_utils.openstack_users']('admin') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


system_upgrade:
  pkg.uptodate:
    - refresh: True


system_minion_openstack_conf:
  file.managed:
    - name: /etc/salt/minion.d/openstack.conf
    - user: root
    - group: root
    - mode: 644
    - contents: |
        keystone.user: admin
        keystone.password: {{ admin_users['admin']['password'] }}
        keystone.tenant: admin
        keystone.auth_url: "http://{{ openstack_parameters['controller_ip'] }}:5000/v2.0"
        keystone.region_name: "RegionOne"


service salt-minion restart: 
  cmd: 
    - run 
    - require: 
       - file: system_minion_openstack_conf
