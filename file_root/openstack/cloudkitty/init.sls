{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - openstack.cloudkitty.packages
  - openstack.cloudkitty.{{ grains['os'] }}.{{ openstack_parameters['series'] }}