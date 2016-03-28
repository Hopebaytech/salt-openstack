{% set neutron = salt['openstack_utils.neutron']() %}
{% set openvswitch = salt['openstack_utils.openvswitch']() %}


openvswitch_interfaces_promisc_upstart_job:
  file.managed:
    - name: {{ openvswitch['conf']['promisc_interfaces'] }}
    - user: root
    - group: root
    - mode: 644
    - contents: |

        start on runlevel [2345]

        script
{% for bridge in neutron['bridges'] %}
  {% if neutron['bridges'][bridge] %}
            ip link set {{ neutron['bridges'][bridge] }} up promisc on
  {% endif %}
{% endfor %}
        end script
    - require:
{% for bridge in neutron['bridges'] %}
  {% if neutron['bridges'][bridge] %}
      - cmd: openvswitch_interface_{{ bridge }}_{{ neutron['bridges'][bridge] }}_up
  {% endif %}
{% endfor %}


openvswitch_promisc_interfaces_script:
  file.managed:
    - name: {{ openvswitch['conf']['promisc_interfaces_script'] }}
    - user: root
    - group: root
    - mode: 755
    - contents: |
        #!/usr/bin/env bash

        {% set defaultgw = salt.network.default_route(family='inet')[0].gateway %}

        # change route to br interface
{% for bridge in neutron['bridges'] %}
  {% if neutron['bridges'][bridge] %}
        {% set ipaddr = salt.network.interface(neutron['bridges'][bridge])[0].address %}
        {% set netmask = salt.network.interface(neutron['bridges'][bridge])[0].netmask %}
        ifconfig {{ bridge }} {{ ipaddr }} netmask {{ netmask }}
        # delete route (default route maybe included)
        ip route flush dev {{ neutron['bridges'][bridge] }}
  {% endif %}
{% endfor %}

        # add default route back
        route add default gw {{ defaultgw }}
    - require:
{% for bridge in neutron['bridges'] %}
  {% if neutron['bridges'][bridge] %}
      - cmd: openvswitch_interface_{{ bridge }}_{{ neutron['bridges'][bridge] }}_up
  {% endif %}
{% endfor %}


openvswitch_promisc_interfaces_script_run:
  cmd.run:
    - name: "sleep 3 && {{ openvswitch['conf']['promisc_interfaces_script'] }}"
    - require:
      - file: {{ openvswitch['conf']['promisc_interfaces_script'] }}


openvswitch_promisc_interfaces_script_upstart_job:
  file.managed:
    - name: {{ openvswitch['conf']['promisc_interfaces_route'] }}
    - user: root
    - group: root
    - mode: 644
    - contents: |
        start on started neutron-plugin-openvswitch-agent

        script

        sleep 3 && {{ openvswitch['conf']['promisc_interfaces_script'] }}

        end script
    - require:
      - cmd: openvswitch_promisc_interfaces_script_run