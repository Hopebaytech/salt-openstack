resources:
  system:
    conf:
      series_persist_file: "/etc/salt/.openstack_series.persist"
      cloudarchive: "/etc/apt/sources.list.d/cloudarchive-openstack.list"
    packages:
      - "python-software-properties"
      - "ubuntu-cloud-keyring"
    repositories:
      openstack:
        series:
          juno: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/juno main"
          kilo: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main"

  ntp:
    packages:
      - "ntp"
    services:
      ntp: "ntp"

  mongodb:
    dirs:
      - "/var/lib/mongodb"
    conf:
      mongod: "/etc/mongodb.conf"
    packages:
      - "mongodb-server"
      - "mongodb-clients"
      - "python-pymongo"
    services:
      mongodb: "mongodb"

  mysql:
    dirs:
      - "/var/lib/mysql"
      - "/etc/mysql"
    conf:
      mysqld: "/etc/mysql/conf.d/mysqld_openstack.cnf"
    packages:
      - "mysql-server-5.5"
      - "mysql-server-core-5.5"
      - "mysql-client-core-5.5"
      - "mysql-common"
      - "python-mysqldb"
    services:
      mysql: "mysql"

  rabbitmq:
    dirs:
      - "/var/lib/rabbitmq"
      - "/etc/rabbitmq"
    services:
      rabbitmq: rabbitmq-server
    packages:
      - "rabbitmq-server"

  ceph:
    packages:
      - "python-rbd"
      - "ceph-common"

  keystone:
    dirs:
      - "/var/lib/keystone"
      - "/etc/keystone"
    openstack_series:
      kilo:
        conf:
          keystone: "/etc/keystone/keystone.conf"
          apache2: "/etc/apache2/apache2.conf"
        packages:
          - "keystone"
          - "python-openstackclient"
          - "apache2"
          - "libapache2-mod-wsgi"
          - "memcached"
          - "python-memcache"
          - "curl"
          - "libnss3-tools"
        services:
          keystone: "keystone"
          apache: "apache2"
        files:
          wsgi_available: "/etc/apache2/sites-available/wsgi-keystone.conf"
          wsgi_enabled: "/etc/apache2/sites-enabled/wsgi-keystone.conf"
          wsgi_components_url: "http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo"
          www: "/var/www/cgi-bin/keystone"
          sqlite: "/var/lib/keystone/keystone.sqlite"
      juno:
        conf:
          keystone: "/etc/keystone/keystone.conf"
        packages:
          - "keystone"
          - "python-keystoneclient"
        services:
          keystone: "keystone"
        files:
          sqlite: "/var/lib/keystone/keystone.db"
      icehouse:
        conf:
          keystone: "/etc/keystone/keystone.conf"
        packages:
          - "keystone"
          - "python-mysqldb"
        services:
          keystone: "keystone"
        files:
          sqlite: "/var/lib/keystone/keystone.db"
          log_dir: "/var/log/keystone"

  glance:
    dirs:
      - "/var/lib/glance"
      - "/etc/glance"
    openstack_series:
      kilo:
        conf:
          api: "/etc/glance/glance-api.conf"
          registry: "/etc/glance/glance-registry.conf"
        packages:
          - "glance"
          - "python-glanceclient"
        services:
          api: "glance-api"
          registry: "glance-registry"
        files:
          images_dir: "/var/lib/glance/images"
          sqlite: "/var/lib/glance/glance.sqlite"
      juno:
        conf:
          api: "/etc/glance/glance-api.conf"
          registry: "/etc/glance/glance-registry.conf"
        packages:
          - "glance"
          - "python-glanceclient"
        services:
          api: "glance-api"
          registry: "glance-registry"
        files:
          images_dir: "/var/lib/glance/images"
          sqlite: "/var/lib/glance/glance.sqlite"
      icehouse:
        conf:
          api: "/etc/glance/glance-api.conf"
          registry: "/etc/glance/glance-registry.conf"
        packages:
          - "glance"
          - "python-glanceclient"
        services:
          api: "glance-api"
          registry: "glance-registry"
        files:
          sqlite: "/var/lib/glance/glance.sqlite"

  nova:
    dirs:
      - "/var/lib/nova"
      - "/etc/nova"
    openstack_series:
      kilo:
        conf:
          nova: "/etc/nova/nova.conf"
          nova_compute: "/etc/nova/nova-compute.conf"
        packages:
          controller:
            - "nova-api"
            - "nova-cert"
            - "nova-conductor"
            - "nova-consoleauth"
            - "nova-novncproxy"
            - "nova-scheduler"
            - "python-novaclient"
          compute:
            kvm:
              - "sysfsutils"
              - "nova-compute"
              - "nova-compute-kvm"
        services:
          controller:
            api: "nova-api"
            cert: "nova-cert"
            consoleauth: "nova-consoleauth"
            scheduler: "nova-scheduler"
            conductor: "nova-conductor"
            novncproxy: "nova-novncproxy"
          compute:
            kvm:
              nova: "nova-compute"
        files:
          nova_tmp: "/var/lib/nova/tmp"
          sqlite: "/var/lib/nova/nova.sqlite"
      juno:
        conf:
          nova: "/etc/nova/nova.conf"
          nova_compute: "/etc/nova/nova-compute.conf"
        packages:
          controller:
            - "nova-api"
            - "nova-cert"
            - "nova-conductor"
            - "nova-consoleauth"
            - "nova-novncproxy"
            - "nova-scheduler"
            - "python-novaclient"
          compute:
            kvm:
              - "sysfsutils"
              - "nova-compute"
              - "nova-compute-kvm"
        services:
          controller:
            api: "nova-api"
            cert: "nova-cert"
            consoleauth: "nova-consoleauth"
            scheduler: "nova-scheduler"
            conductor: "nova-conductor"
            novncproxy: "nova-novncproxy"
          compute:
            kvm:
              nova: "nova-compute"
        files:
          sqlite: "/var/lib/nova/nova.sqlite"
      icehouse:
        conf:
          nova: "/etc/nova/nova.conf"
          nova_compute: "/etc/nova/nova-compute.conf"
        packages:
          controller:
            - "nova-api"
            - "nova-cert"
            - "nova-conductor"
            - "nova-consoleauth"
            - "nova-novncproxy"
            - "nova-scheduler"
            - "python-novaclient"
          compute:
            kvm:
              - "nova-compute-kvm"
        services:
          controller:
            api: "nova-api"
            cert: "nova-cert"
            consoleauth: "nova-consoleauth"
            scheduler: "nova-scheduler"
            conductor: "nova-conductor"
            novncproxy: "nova-novncproxy"
          compute:
            kvm:
              nova: "nova-compute"
        files:
          sqlite: "/var/lib/nova/nova.sqlite"

  neutron:
    dirs:
      - "/var/lib/neutron"
      - "/etc/neutron"
    openstack_series:
      kilo:
        conf:
          neutron: "/etc/neutron/neutron.conf"
          sysctl: "/etc/sysctl.conf"
          ml2: "/etc/neutron/plugins/ml2/ml2_conf.ini"
          l3_agent: "/etc/neutron/l3_agent.ini"
          dhcp_agent: "/etc/neutron/dhcp_agent.ini"
          dnsmasq_config_file: "/etc/neutron/dnsmasq-neutron.conf"
          metadata_agent: "/etc/neutron/metadata_agent.ini"
          lbaas_agent: "/etc/neutron/lbaas_agent.ini"
        packages:
          controller:
            - "neutron-server"
            - "neutron-plugin-ml2"
            - "python-neutronclient"
            - "python-neutron-lbaas"
          compute:
            kvm:
              - "neutron-plugin-ml2"
              - "neutron-plugin-openvswitch-agent"
          network:
            - "openvswitch-switch"
            - "neutron-plugin-openvswitch-agent"
            - "neutron-plugin-ml2"
            - "neutron-l3-agent"
            - "neutron-dhcp-agent"
            - "neutron-metadata-agent"
            - "python-neutronclient"
            - "neutron-lbaas-agent"
            - "conntrack"
        services:
          controller:
            neutron_server: "neutron-server"
          compute:
            kvm:
              ovs: "openvswitch-switch"
              ovs_agent: "neutron-plugin-openvswitch-agent"
          network:
            l3_agent: "neutron-l3-agent"
            dhcp_agent: "neutron-dhcp-agent"
            metadata_agent: "neutron-metadata-agent"
            ovs: "openvswitch-switch"
            ovs_agent: "neutron-plugin-openvswitch-agent"
      juno:
        conf:
          neutron: "/etc/neutron/neutron.conf"
          sysctl: "/etc/sysctl.conf"
          ml2: "/etc/neutron/plugins/ml2/ml2_conf.ini"
          l3_agent: "/etc/neutron/l3_agent.ini"
          dhcp_agent: "/etc/neutron/dhcp_agent.ini"
          dnsmasq_config_file: "/etc/neutron/dnsmasq-neutron.conf"
          metadata_agent: "/etc/neutron/metadata_agent.ini"
        packages:
          controller:
            - "neutron-server"
            - "neutron-plugin-ml2"
            - "python-neutronclient"
          compute:
            kvm:
              - "neutron-plugin-ml2"
              - "neutron-plugin-openvswitch-agent"
          network:
            - "openvswitch-switch"
            - "neutron-plugin-openvswitch-agent"
            - "neutron-plugin-ml2"
            - "neutron-l3-agent"
            - "neutron-dhcp-agent"
            - "neutron-metadata-agent"
            - "python-neutronclient"
            - "conntrack"
        services:
          controller:
            neutron_server: "neutron-server"
          compute:
            kvm:
              ovs: "openvswitch-switch"
              ovs_agent: "neutron-plugin-openvswitch-agent"
          network:
            l3_agent: "neutron-l3-agent"
            dhcp_agent: "neutron-dhcp-agent"
            metadata_agent: "neutron-metadata-agent"
            ovs: "openvswitch-switch"
            ovs_agent: "neutron-plugin-openvswitch-agent"
      icehouse:
        conf:
          neutron: "/etc/neutron/neutron.conf"
          sysctl: "/etc/sysctl.conf"
          ml2: "/etc/neutron/plugins/ml2/ml2_conf.ini"
          l3_agent: "/etc/neutron/l3_agent.ini"
          dhcp_agent: "/etc/neutron/dhcp_agent.ini"
          dnsmasq_config_file: "/etc/neutron/dnsmasq-neutron.conf"
          metadata_agent: "/etc/neutron/metadata_agent.ini"
        packages:
          controller:
            - "neutron-server"
            - "neutron-plugin-ml2"
          compute:
            kvm:
              - "neutron-common"
              - "neutron-plugin-ml2"
              - "neutron-plugin-openvswitch-agent"
              - "openvswitch-datapath-dkms"
              - "python-mysqldb"
          network:
            - "neutron-plugin-ml2"
            - "neutron-plugin-openvswitch-agent"
            - "openvswitch-datapath-dkms"
            - "neutron-l3-agent"
            - "neutron-dhcp-agent"
            - "openvswitch-switch"
            - "neutron-metadata-agent"
        services:
          controller:
            neutron_server: "neutron-server"
          compute:
            kvm:
              ovs: "openvswitch-switch"
              ovs_agent: "neutron-plugin-openvswitch-agent"
          network:
            l3_agent: "neutron-l3-agent"
            dhcp_agent: "neutron-dhcp-agent"
            metadata_agent: "neutron-metadata-agent"
            ovs: "openvswitch-switch"
            ovs_agent: "neutron-plugin-openvswitch-agent"

  openvswitch:
    conf:
      promisc_interfaces: "/etc/init/openstack-promisc-interfaces.conf"
      promisc_interfaces_script: "/root/openstack-promisc-interfaces.sh"
      promisc_interfaces_route: "/etc/init/openstack-promisc-interfaces-route.conf"
      interfaces: "/etc/network/interfaces"

  horizon:
    dirs:
      - "/var/lib/openstack-dashboard"
      - "/etc/openstack-dashboard"
    conf:
      local_settings: "/etc/openstack-dashboard/local_settings.py"
      apache2: "/etc/apache2/conf-available/openstack-dashboard.conf"
      ubuntu_theme: "openstack-dashboard-ubuntu-theme"
    packages:
      - "openstack-dashboard"
      - "apache2"
      - "libapache2-mod-wsgi"
      - "memcached"
      - "python-memcache"
    services:
      apache: "apache2"
      memcached: "memcached"

  cinder:
    dirs:
      - "/var/lib/cinder"
      - "/etc/cinder"
    openstack_series:
      kilo:
        conf:
          cinder: "/etc/cinder/cinder.conf"
          losetup_upstart: "/etc/init/openstack-cinder-losetup.conf"
        packages:
          controller:
            - "cinder-api"
            - "cinder-scheduler"
            - "python-cinderclient"
          storage:
            - "cinder-volume"
            - "python-mysqldb"
        services:
          controller:
            scheduler: "cinder-scheduler"
            api: "cinder-api"
          storage:
            tgt: "tgt"
            cinder_volume: "cinder-volume"
        files:
          lock: "/var/lock/cinder"
          sqlite: "/var/lib/cinder/cinder.sqlite"
      juno:
        conf:
          cinder: "/etc/cinder/cinder.conf"
          losetup_upstart: "/etc/init/openstack-cinder-losetup.conf"
        packages:
          controller:
            - "cinder-api"
            - "cinder-scheduler"
            - "python-cinderclient"
          storage:
            - "cinder-volume"
            - "python-mysqldb"
        services:
          controller:
            scheduler: "cinder-scheduler"
            api: "cinder-api"
          storage:
            tgt: "tgt"
            cinder_volume: "cinder-volume"
        files:
          sqlite: "/var/lib/cinder/cinder.sqlite"
      icehouse:
        conf:
          cinder: "/etc/cinder/cinder.conf"
          losetup_upstart: "/etc/init/openstack-cinder-losetup.conf"
        packages:
          controller:
            - "cinder-api"
            - "cinder-scheduler"
          storage:
            - "cinder-volume"
            - "python-mysqldb"
        services:
          controller:
            scheduler: "cinder-scheduler"
            api: "cinder-api"
          storage:
            tgt: "tgt"
            cinder_volume: "cinder-volume"
        files:
          sqlite: "/var/lib/cinder/cinder.sqlite"

  heat:
    dirs:
      - "/var/lib/heat"
      - "/etc/heat"
    openstack_series:
      kilo:
        conf:
          heat: "/etc/heat/heat.conf"
        packages:
          - "heat-api"
          - "heat-api-cfn"
          - "heat-engine"
          - "python-heatclient"
        services:
          api: "heat-api"
          api_cfn: "heat-api-cfn"
          engine: "heat-engine"
        files:
          sqlite: "/var/lib/heat/heat.sqlite"
      juno:
        conf:
          heat: "/etc/heat/heat.conf"
        packages:
          - "heat-api"
          - "heat-api-cfn"
          - "heat-engine"
          - "python-heatclient"
        services:
          api: "heat-api"
          api_cfn: "heat-api-cfn"
          engine: "heat-engine"
        files:
          sqlite: "/var/lib/heat/heat.sqlite"
      icehouse:
        conf:
          heat: "/etc/heat/heat.conf"
        packages:
          - "heat-api"
          - "heat-api-cfn"
          - "heat-engine"
        services:
          api: "heat-api"
          api_cfn: "heat-api-cfn"
          engine: "heat-engine"
        files:
          sqlite: "/var/lib/heat/heat.sqlite"
          log_dir: "/var/log/heat"

  ceilometer:
    dirs:
      - "/var/lib/ceilometer"
      - "/etc/ceilometer"
    openstack_series:
      kilo:
        conf:
          ceilometer: "/etc/ceilometer/ceilometer.conf"
          ceilometer_compute: "/etc/nova/nova.conf"
          ceilometer_volume: "/etc/cinder/cinder.conf"
          ceilometer_image_api: "/etc/glance/glance-api.conf"
          ceilometer_image_registry: "/etc/glance/glance-registry.conf"
        packages:
          controller:
            - "ceilometer-api"
            - "ceilometer-collector"
            - "ceilometer-agent-central"
            - "ceilometer-agent-notification"
            - "ceilometer-alarm-evaluator"
            - "ceilometer-alarm-notifier"
            - "python-ceilometerclient"
            - "python-awsauth"
          compute:
            - "ceilometer-agent-compute"
        services:
          controller:
            agent-central: "ceilometer-agent-central"
            agent-notification: "ceilometer-agent-notification"
            api: "ceilometer-api"
            collector: "ceilometer-collector"
            alarm-evaluator: "ceilometer-alarm-evaluator"
            alarm-notifier: "ceilometer-alarm-notifier"
          compute:
            agent-compute: "ceilometer-agent-compute"
        files:
          sqlite: "/var/lib/ceilometer/ceilometer.sqlite"
      juno:
        conf:
          ceilometer: "/etc/ceilometer/ceilometer.conf"
          ceilometer_compute: "/etc/nova/nova.conf"
          ceilometer_volume: "/etc/cinder/cinder.conf"
          ceilometer_image_api: "/etc/glance/glance-api.conf"
          ceilometer_image_registry: "/etc/glance/glance-registry.conf"
        packages:
          controller:
            - "ceilometer-api"
            - "ceilometer-collector"
            - "ceilometer-agent-central"
            - "ceilometer-agent-notification"
            - "ceilometer-alarm-evaluator"
            - "ceilometer-alarm-notifier"
            - "python-ceilometerclient"
            - "python-awsauth"
          compute:
            - "ceilometer-agent-compute"
        services:
          controller:
            agent-central: "ceilometer-agent-central"
            agent-notification: "ceilometer-agent-notification"
            api: "ceilometer-api"
            collector: "ceilometer-collector"
            alarm-evaluator: "ceilometer-alarm-evaluator"
            alarm-notifier: "ceilometer-alarm-notifier"
          compute:
            agent-compute: "ceilometer-agent-compute"
        files:
          sqlite: "/var/lib/ceilometer/ceilometer.sqlite"

  cloudkitty:
    conf:
      cloudkitty: "/etc/apt/sources.list.d/cloudkitty-kilo.list"
    packages:
      - "ubuntu-cloud-keyring"
    repositories:
      openstack:
        series:
          kilo: "deb http://archive.objectif-libre.com/cloudkitty/ubuntu trusty/kilo main"
    openstack_series:
      kilo:
        conf:
          cloudkitty: "/etc/cloudkitty/cloudkitty.conf"
        packages:
          - "python-cloudkittyclient"
          - "cloudkitty-api"
          - "cloudkitty-processor"
          - "cloudkitty-dashboard"
        services:
          api: "cloudkitty-api"
          processor: "cloudkitty-processor"

  trove:
    dirs:
      - "/var/lib/trove"
      - "/etc/trove"
    openstack_series:
      kilo:
        conf:
          trove: "/etc/trove/trove.conf"
          trove_conductor: "/etc/trove/trove-conductor.conf"
          trove_taskmanager: "/etc/trove/trove-taskmanager.conf"
        cloudinit:
          mysql: "/etc/trove/cloudinit/mysql.cloudinit"
        packages:
          - "trove-api"
          - "trove-common"
          - "trove-taskmanager"
          - "trove-conductor"
          - "python-troveclient"
          - "python-trove"
        services:
          trove_api: "trove-api"
          trove_conductor: "trove-conductor"
          trove_taskmanager: "trove-taskmanager"
        files:
          sqlite: "/var/lib/trove/trove_test.sqlite"