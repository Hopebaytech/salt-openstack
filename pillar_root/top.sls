openstack: 
  "controller1,neutron1,compute1,compute2":
    - match: list
    - {{ grains['os'] }}
    - cc2kilo_template.credentials
    - cc2kilo_template.environment
    - cc2kilo_template.networking
