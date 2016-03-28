{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - openstack.trove.packages
  - openstack.trove.{{ grains['os'] }}.{{ openstack_parameters['series'] }}