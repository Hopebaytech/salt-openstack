{% set trove = salt['openstack_utils.trove']() %}
{% set admin_users = salt['openstack_utils.openstack_users']('admin') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}
{% set keystone = salt['openstack_utils.keystone']() %}


trove_get_image_id:
  file.managed:
    - name: "/tmp/getimgid.sh"
    - user: root
    - group: root
    - mode: 755
    - contents: |
        #!/usr/bin/env bash

        export OS_USERNAME=admin
        export OS_PROJECT_NAME=admin
        export OS_TENANT_NAME=admin
        export OS_PASSWORD={{ admin_users['admin']['password'] }}
        export OS_AUTH_URL={{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }}
        export OS_VOLUME_API_VERSION=2
        export OS_IMAGE_API_VERSION=2

        glance image-list | awk "/ $1 / {print \$2}" | xargs echo -n

    - require:
      - file: trove_mysql_cloud_init


{% set dbtype = 'mysql' %}
{% set users = salt['openstack_utils.openstack_users'](trove['images'][dbtype]['tenant']) %}
trove_{{ dbtype }}_image_create:
  glance.image_present:
    - name: {{ trove['images'][dbtype]['name'] }}
    - connection_user: {{ trove['images'][dbtype]['user'] }}
    - connection_tenant: {{ trove['images'][dbtype]['tenant'] }}
    - connection_password: {{ users[trove['images'][dbtype]['user']]['password'] }}
    - connection_auth_url: {{ keystone['openstack_services']['keystone']['endpoint']['internalurl'].format(openstack_parameters['controller_ip']) }}
  {% for param in trove['images'][dbtype]['parameters'] %}
    - {{ param }}: {{ trove['images'][dbtype]['parameters'][param] }}
  {% endfor %}
    - require:
      - file: trove_mysql_cloud_init
      # required only when ceph with glance is used 
      - cmd: glance_ceph_wait


{% set dbtype = 'mysql' %}
trove_{{ dbtype }}_image_datastore:
  cmd.run:
    - name: "sleep 5 && trove-manage datastore_update mysql '' && \
             trove-manage datastore_version_update mysql 5.5 mysql `/tmp/getimgid.sh '{{ trove['images'][dbtype]['name'] }}'` 'mysql-server-5.5' 1 && \
             trove-manage datastore_version_update mysql 5.5-debian mysql `/tmp/getimgid.sh '{{ trove['images'][dbtype]['name'] }}'` 'mysql-server-5.5' 1 && \
             trove-manage datastore_update mysql 5.5-debian && \
             trove-manage db_load_datastore_config_parameters mysql 5.5-debian /usr/lib/python2.7/dist-packages/trove/templates/mysql/validation-rules.json && \
             trove-manage db_load_datastore_config_parameters mysql 5.5 /usr/lib/python2.7/dist-packages/trove/templates/mysql/validation-rules.json"
    - require:
      - glance: trove_{{ dbtype }}_image_create