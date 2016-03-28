{% set keystone = salt['openstack_utils.keystone']() %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}
{% set ceph = salt['pillar.get']('ceph', default=[]) %}


radosgw_key:
  file.managed:
    - name: "/tmp/arkflexu.rsa"
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: arkflex:id_rsa
    - require:
      - cmd: keystone_nss_cert


radosgw_cfg:
  file.managed:
    - name: '/tmp/radosgwcfg.py'
    - user: root
    - group: root
    - mode: 644
    - contents: |
        import ConfigParser

        config = ConfigParser.RawConfigParser()
        config.readfp(open('/etc/ceph/ceph.conf'))
        config.set('client.radosgw.gateway', 'rgw keystone url', 'http://{{ openstack_parameters['controller_ip'] }}:35357')
        config.set('client.radosgw.gateway', 'rgw keystone admin token', '{{ keystone['admin_token'] }}')
        config.set('client.radosgw.gateway', 'rgw keystone accepted roles', 'admin, _member_, swiftoperator')
        config.set('client.radosgw.gateway', 'rgw keystone token cache size', '100')
        config.set('client.radosgw.gateway', 'rgw keystone revocation interval', '600')
        config.set('client.radosgw.gateway', 'rgw s3 auth use keystone', 'true')
        config.set('client.radosgw.gateway', 'nss db path', '/data/ceph/nss')

        with open('/etc/ceph/ceph.conf', 'wb') as configfile:
            config.write(configfile)
    - require:
      - file: radosgw_key


radosgw_files:
  cmd.run:
    - name: "scp -o StrictHostKeyChecking=no -i /tmp/arkflexu.rsa /tmp/radosgwcfg.py root@{{ ceph['radosgw']['ip'] }}:/tmp/ &&\
             ssh -o StrictHostKeyChecking=no -i /tmp/arkflexu.rsa root@{{ ceph['radosgw']['ip'] }} 'mkdir -p /data/ceph' &&\
             scp -o StrictHostKeyChecking=no -i /tmp/arkflexu.rsa -r /var/ceph/nss root@{{ ceph['radosgw']['ip'] }}:/data/ceph/"
    - require:
      - file: radosgw_cfg


radosgw_restart:
  cmd.run:
    - name: "ssh -o StrictHostKeyChecking=no -i /tmp/arkflexu.rsa root@{{ ceph['radosgw']['ip'] }} 'python /tmp/radosgwcfg.py && /etc/init.d/radosgw restart'"
    - require:
      - cmd: radosgw_files