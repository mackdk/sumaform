{% if 'proxy' in grains.get('roles') %}
include:
  {%- if '4.3' in grains['product_version'] %}
  - repos.proxy43
  {%- else %}
  # Non-podman version deprecated in September 2024:
  - repos.proxyUyuni
  {%- endif %}

{% endif %}

# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []
