routes:
  config:
  - destination: 0.0.0.0/0
    metric: 100
    next-hop-address: 192.168.0.1
    next-hop-interface: mgmt-br
    table-id: 254
  - destination: 192.168.0.0/24
    metric: 100
    next-hop-address:
    next-hop-interface: mgmt-br
    table-id: 254
dns-resolver:
  config:
    search:
    - example.com
    server:
    - 192.168.0.1
interfaces:
- name: enp0s1
  type: ethernet
  state: up
  mac:address: de:ad:be:ef:00:01
  ipv4:
    enabled: false
  ipv6:
    enabled: false
- name: mgmt-bo
  type: bond
  state: up
  ipv4:
    enabled: false
  ipv6:
    enabled: false
  link-aggregation:
    mode: active-backup
    port:
      - enp0s1
- name: mgmt-br
  type: linux-bridge
  state: up
  ipv4:
    enabled: true
    dhcp: false
    address:
      - ip: 192.168.0.101
        prefix-length: 24
  ipv6:
    enabled: false
  bridge:
    options:
      stp:
        enabled: false
    port:
      - name: mgmt-bo
        # Trunk all VLANs with VLAN 1 untagged, so VM VLAN networks on mgmt work.
        # Verify after boot: `bridge -d vlan show` and /sys/class/net/mgmt-br/bridge/vlan_filtering
        vlan:
          mode: trunk
          enable-native: true
          tag: 1
          trunk-tags:
            - id-range:
                min: 2
                max: 4094
