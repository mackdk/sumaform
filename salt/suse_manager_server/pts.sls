{% if grains.get('pts') %}
pts_runner:
  file.managed:
    - name: /usr/bin/run-pts
    - source: salt://suse_manager_server/pts/run-pts.py
    - mode: 755
{% endif %}
