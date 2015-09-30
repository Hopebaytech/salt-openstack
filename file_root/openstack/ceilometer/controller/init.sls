{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


include:
  - openstack.ceilometer.controller.packages
  - openstack.ceilometer.message_queue.{{ openstack_parameters['series'] }}.{{ openstack_parameters['message_queue'] }}
  - openstack.ceilometer.controller.{{ grains['os'] }}.{{ openstack_parameters['series'] }}
