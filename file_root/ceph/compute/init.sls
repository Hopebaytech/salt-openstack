{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - ceph.compute.packages
  - ceph.compute.{{ grains['os'] }}.{{ openstack_parameters['series'] }}