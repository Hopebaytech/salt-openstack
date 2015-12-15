{% set cloudkitty = salt['openstack_utils.cloudkitty']() %}
{% set keystone = salt['openstack_utils.keystone']() %}
{% set tenant_users = salt['openstack_utils.openstack_users']('service') %}
{% set openstack_parameters = salt['openstack_utils.openstack_parameters']() %}


{% for pkg in cloudkitty['packages'] %}
cloudkitty_{{ pkg }}_install:
  pkg.installed:
    - name: {{ pkg }}
    - require:
      - pkg: cloudkitty_repository_update
{% endfor %}

cloudkitty_repository_update:
  pkg.uptodate:
    - refresh: True
    - require:
      - cmd: cloudkitty_repository_ppa_keys

cloudkitty_repository_openstack_repo_absent:
  file.absent:
    - name: {{ cloudkitty['path'] }}

cloudkitty_repository_openstack_repo_create:
  file.managed:
    - name: {{ cloudkitty['path'] }}
    - contents: {{ cloudkitty['deb_repo'] }}
    - require:
      - file: system_repository_openstack_repo_absent

cloudkitty_repository_ppa_keys:
  cmd.run:
    - name: "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 71E414B3"
    - unless: 'apt-key list | grep 71E414B3'
    - require:
      - file: cloudkitty_repository_openstack_repo_create

cloudkitty_horzion_symlink_static:
  file.symlink:
    - name: /usr/share/openstack-dashboard/static/cloudkitty
    - target: /usr/lib/python2.7/dist-packages/cloudkittydashboard/static/cloudkitty
    - require:
{% for pkg in cloudkitty['packages'] %}
      - pkg: cloudkitty_{{ pkg }}_install
{% endfor %}

cloudkitty_patch_quote_uri:
  file.replace:
    - name: "/usr/lib/python2.7/dist-packages/cloudkittydashboard/static/cloudkitty/js/pricing.js"
    - pattern: "/project/rating/quote"
    - repl: "/dashboard/project/rating/quote"
    - require:
      - file: cloudkitty_horzion_symlink_static

cloudkitty_admin_tenant:
  keystone:
    - user_present
    - name: "cloudkitty"
    - password: {{ tenant_users['cloudkitty']['password'] }}
    - email: {{ tenant_users['cloudkitty']['email'] }}
    - tenant: "admin"
    - roles:
      - "admin": {{ tenant_users['cloudkitty']['roles'] }}
    - connection_token: "{{ keystone['admin_token'] }}"
    - connection_endpoint: "{{ keystone['openstack_services']['keystone']['endpoint']['adminurl'].format(openstack_parameters['controller_ip']) }}"