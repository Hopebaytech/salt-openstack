mysql:
  root_password: "RandomPassword123"

rabbitmq:
  user_name: "openstack"
  user_password: "RandomPassword123"

databases:
  nova:
    db_name: "nova"
    username: "nova"
    password: "RandomPassword123"
  keystone:
    db_name: "keystone"
    username: "keystone"
    password: "RandomPassword123"
  cinder:
    db_name: "cinder"
    username: "cinder"
    password: "RandomPassword123"
  glance:
    db_name: "glance"
    username: "glance"
    password: "RandomPassword123"
  neutron:
    db_name: "neutron"
    username: "neutron"
    password: "RandomPassword123"
  heat:
    db_name: "heat"
    username: "heat"
    password: "RandomPassword123"
  ceilometer:
    db_name: "ceilometer"
    username: "ceilometer"
    password: "RandomPassword123"
  cloudkitty:
    db_name: "cloudkitty"
    username: "cloudkitty"
    password: "RandomPassword123"
  trove:
    db_name: "trove"
    username: "trove"
    password: "RandomPassword123"

neutron:
  metadata_secret: "RandomPassword123"

keystone:
  admin_token: "RandomPassword123"
  roles:
    - "admin"
    - "heat_stack_owner"
    - "heat_stack_user"
    - "rating"
  tenants:
    admin:
      users:
        admin:
          password: "RandomPassword123"
          roles:
            - "admin"
            - "heat_stack_owner"
          email: "salt@openstack.com"
          keystonerc:
            create: True
            path: /root/keystonerc_admin
    mocha:
      users:
        mochauser:
          password: "mochamocha"
          roles:
            - "rating"
          email: "salt@openstack.com"
    service:
      users:
        cinder:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        glance:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        neutron:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        nova:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        heat:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        heat-cfn:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        ceilometer:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        cloudkitty:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        trove:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"
        swift:
          password: "RandomPassword123"
          roles:
            - "admin"
          email: "salt@openstack.com"

ceilometer:
  metering_secret: "RandomPassword123"