{% set ceilometer = salt['openstack_utils.ceilometer']() %}
{% set cinder = salt['openstack_utils.cinder']() %}


ceilometer_storage_conf_cinder:
  ini.options_present:
    - name: {{ ceilometer['conf']['ceilometer_volume'] }}
    - sections:
        DEFAULT:
          control_exchange: cinder
          notification_driver: messagingv2


# service cinder-volume
{% for service in cinder['services']['storage'] %}
ceilometer_cinder_storage_{{ service }}_running:
  service.running:
    - enable: True
    - name: {{ cinder['services']['storage'][service] }}
    - watch:
      - ini: ceilometer_storage_conf_cinder
{% endfor %}


ceilometer_cinder_storage_wait:
  cmd.run:
    - name: sleep 5
    - require:
{% for service in cinder['services']['storage'] %}
      - service: ceilometer_cinder_storage_{{ service }}_running
{% endfor %}
