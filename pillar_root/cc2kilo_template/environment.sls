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

glance:
  images:
    cirros:
      user: "admin"
      tenant: "admin"
      parameters:
        min_disk: 1
        min_ram: 0
        copy_from: "http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img"
        disk_format: qcow2
        container_format: bare
        is_public: True
        protected: False

trove:
  images:
    mysql:
      name: "MySQL 5.5 Debian"
      user: "admin"
      tenant: "admin"
      parameters:
        min_disk: 8
        min_ram: 0
        copy_from: "https://61.219.202.67:8080/images/mysql-debian.qcow2"
        disk_format: qcow2
        container_format: bare
        is_public: True
        protected: False

ceph:
    monitors:
      - "10.10.99.68:6789"
      - "10.10.99.66:6789"
      - "10.10.99.67:6789"
      - "10.10.99.69:6789"
    cinder:
      user: "cinder4"
      keyring: "AQDvYuZWIF/nGxAAKZdvuqfyBH5zgtnVDbY/rQ=="
      diskpool: "volumes4-disk"
      ssdpool: "volumes4-ssd"
    glance:
      user: "glance4"
      keyring: "AQADY+ZWwAdfOBAAOqnB64gn3LUW5YRP39BDLQ=="
      pool: "images4"
    radosgw:
      ip: "10.10.99.68"

arkflex:
  id_rsa: |
    -----BEGIN RSA PRIVATE KEY-----
    Your Key here
    -----END RSA PRIVATE KEY-----

