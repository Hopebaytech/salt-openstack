neutron:
  integration_bridge: "br-int"

  external_bridge: "br-ex"

  single_nic:
    enable: False
    interface: "eth0"
    set_up_script: "/root/br-proxy.sh"

  type_drivers:
    flat:
      physnets:
        physnet0:
          bridge: "br-ex"
          hosts:
            "controller01": "eth0"
            "neutron01": "eth0"
            "compute01": "eth0"
            "compute02": "eth0"
    vxlan:
      physnets:
        physnet1:
          bridge: "br-data"
          hosts:
            "controller01": "eth1"
            "neutron01": "eth1"
            "compute01": "eth1"
            "compute02": "eth1"
      vxlan_group: "239.1.1.1"
      tunnels:
        tunnel_1:
          vni_range: "100:1000"

  tunneling:
    enable: True
    types:
      - vxlan
    bridge: "br-tun"

  networks:
    public:
      user: "admin"
      tenant: "admin"
      shared: True
      admin_state_up: True
      router_external: True
      provider_physical_network: "physnet0"
      provider_network_type: "flat"
      subnets:
        public_subnet:
          cidr: '10.0.0.0/8'
          allocation_pools:
            - start: '10.10.95.10'
              end: '10.10.95.200'
          enable_dhcp: False
          gateway_ip: "10.0.0.1"
    private:
      user: "admin"
      tenant: "admin"
      admin_state_up: True
      subnets:
        private_subnet:
          cidr: '192.168.111.0/24'
          enable_dhcp: True
          dns_nameservers:
            - 8.8.8.8

  routers:
    router1:
      user: "admin"
      tenant: "admin"
      interfaces:
        - "private_subnet"
      gateway_network: "public"

  security_groups:
    default:
      user: admin
      tenant: admin
      description: 'default'
      rules: # Allow all traffic on the default security group
        - direction: "ingress"
          ethertype: "IPv4"
          protocol: "TCP"
          port_range_min: "1"
          port_range_max: "65535"
          remote_ip_prefix: "0.0.0.0/0"
        - direction: "ingress"
          ethertype: "IPv4"
          protocol: "UDP"
          port_range_min: "1"
          port_range_max: "65535"
          remote_ip_prefix: "0.0.0.0/0"
        - direction: ingress
          protocol: ICMP
          remote_ip_prefix: '0.0.0.0/0'
