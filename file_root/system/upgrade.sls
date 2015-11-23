system_upgrade:
  pkg.uptodate:
    - refresh: True


system_restart_salt_minion:
  cmd.run:
  - name: "service salt-minion restart && sleep 3"
  - require:
      - pkg: system_upgrade
