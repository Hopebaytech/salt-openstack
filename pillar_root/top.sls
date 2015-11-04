openstack: 
  "controller01,neutron01,compute01,compute02":
    - match: list
    - {{ grains['os'] }}
    - cc2kilo_template.credentials
    - cc2kilo_template.environment
    - cc2kilo_template.networking
