{% if grains['os_family'] == 'RedHat' %}
{% if grains['osfinger'] == 'Red Hat Enterprise Linux-9' or grains['osfinger'] == 'Amazon Linux-2023' %}
install_dbus_uuidgen:
  pkg.installed:
    - pkgs:
      - dbus-tools
{% endif %}
{% endif %}

systemd_machine_id:
  cmd.run:
    - name: |
        bash -c '
        rm -f /etc/machine-id
        rm -f /var/lib/dbus/machine-id
        mkdir -p /var/lib/dbus
        dbus-uuidgen --ensure
        systemd-machine-id-setup
        if [ -d /var/log/journal ] && [ "$(ls -A /var/log/journal)" ]; then
          mkdir -p /var/log/journal/$(cat /etc/machine-id)
          find /var/log/journal -mindepth 1 -maxdepth 1 ! -name "$(cat /etc/machine-id)" -exec mv {} /var/log/journal/$(cat /etc/machine-id)/ \;
        fi
        touch /etc/machine-id-already-setup
        '
    - creates: /etc/machine-id-already-setup
    - onlyif: test -f /usr/bin/systemd-machine-id-setup -o -f /bin/systemd-machine-id-setup

dbus_machine_id:
  cmd.run:
    - name: rm -f /var/lib/dbus/machine-id && dbus-uuidgen --ensure
    - creates: /var/lib/dbus/machine-id
    - unless: test -f /usr/bin/systemd-machine-id-setup -o -f /bin/systemd-machine-id-setup

minion_id_cleared:
  file.absent:
{% if grains['install_salt_bundle'] %}
    - name: /etc/venv-salt-minion/minion_id
{% else %}
    - name: /etc/salt/minion_id
{% endif %}
