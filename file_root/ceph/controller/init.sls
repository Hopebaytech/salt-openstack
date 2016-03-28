{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - ceph.controller.packages
  - ceph.controller.cert
  - ceph.controller.{{ grains['os'] }}.{{ openstack_parameters['series'] }}
  - ceph.controller.radosgw
  - openstack.glance.images
  - openstack.trove.images
