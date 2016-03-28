{% set ceph = salt['pillar.get']('ceph', default=[]) %}


/etc/ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - require:
{% for pkg in salt['pillar.get']('resources:ceph')['packages'] %}
      - pkg: ceph_compute_{{ pkg }}_install
{% endfor %}


ceph_conf:
  file.managed:
    - name: "/etc/ceph/ceph.conf"
    - user: root
    - group: root
    - mode: 644
    - contents: |
        {% for monaddr in ceph['monitors'] %}
        [mon.mon-{{ loop.index }}]
        host = mon-{{ loop.index }}
        mon addr = {{ monaddr }}
        {% endfor %}
    - require:
      - file: /etc/ceph


cinder_compute_keyring:
  file.managed:
    - name: "/etc/ceph/ceph.client.{{ ceph['cinder']['user'] }}.keyring"
    - user: root
    - group: root
    - mode: 644
    - contents: |
        [client.{{ ceph['cinder']['user'] }}]
            key = {{ ceph['cinder']['keyring'] }}
    - require:
      - file: /etc/ceph


virsh_secret:
  file.managed:
    - name: "/tmp/secret.xml"
    - user: root
    - group: root
    - mode: 644
    - contents: |
        <secret ephemeral='no' private='no'>
          <uuid>457eb676-33da-42ec-9a8c-9293d545c337</uuid>
          <usage type='ceph'>
            <name>client.cinder secret</name>
          </usage>
        </secret>
    - require:
      - file: cinder_compute_keyring


virsh_secret_define:
  cmd.run:
    - name: "virsh secret-define --file /tmp/secret.xml && virsh secret-set-value --secret 457eb676-33da-42ec-9a8c-9293d545c337 --base64 {{ ceph['cinder']['keyring'] }}"
    - require:
      - file: virsh_secret