{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - openstack.ceilometer.storage.{{ grains['os'] }}.{{ openstack_parameters['series'] }}
