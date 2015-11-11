environment_name: "cc2kilo_template"

openstack_series: "kilo"

db_engine: "mysql"

message_queue_engine: "rabbitmq"

reset: "soft"

debug_mode: False

system_upgrade: True

hosts:
  "controller01": "10.10.99.41"
  "neutron01": "10.10.99.42"
  "compute01": "10.10.99.43"
  "compute02": "10.10.99.44"

hosts_int:
  "controller01": "192.168.250.41"
  "neutron01": "192.168.250.42"
  "compute01": "192.168.250.43"
  "compute02": "192.168.250.44"

controller: "controller01"
network: "neutron01"
storage:
  - "controller01"
compute:
  - "compute01"
  - "compute02"

cinder:
  volumes_group_name: "cinder-volumes"
  volumes_path: "/var/lib/cinder/cinder-volumes"
  volumes_group_size: "100"
  loopback_device: "/dev/loop0"

nova:
  cpu_allocation_ratio: "16"
  ram_allocation_ratio: "1.5"

#glance:
#  images:
#    cirros:
#      user: "admin"
#      tenant: "admin"
#      parameters:
#        min_disk: 1
#        min_ram: 0
#        copy_from: "http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img"
#        disk_format: qcow2
#        container_format: bare
#        is_public: True
#        protected: False
