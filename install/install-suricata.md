# See https://vietnix.vn/cai-dat-suricata-tren-ubuntu-20-04/ for more details

# Step 1: Install Suricata
```bash
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt install suricata
sudo systemctl enable suricata.service
```

Before configuring Suricata, stop the service with the following command: 
```bash
sudo systemctl stop suricata.service
```

# Step 2: config Suricata for the first time:
```bash
sudo nano /etc/suricata/suricata.yaml
```
Find line 120 that says # Community Flow ID if you are using nano type CRTL+_ and then enter 120 when prompted for a line number. Below line 120 is community-id, set to true to enable the setting:
```yaml
      # Community Flow ID
      # Adds a 'community_id' field to EVE records. These are meant to give
      # records a predictable flow ID that can be used to match records to
      # output of other tools such as Zeek (Bro).
      #
      # Takes a 'seed' that needs to be same across sensors and tools
      # to make the id less predictable.

      # enable/disable the community id feature.
      community-id: true
```

# Step 3: Identify the interface(s) to use
You need to override the default interface or the interface you want Suricata to monitor traffic on. The configuration file that comes with the OISF package Suricata monitors traffic on port eth0 by default. If your system uses a different network interface or if you want to monitor traffic on multiple interfaces, you will need to change this value.

To identify the device name of the interface, you can use the following command:

```bash
ip -p -j route show default
```
The -p flag formats the output and the -j flag prints the output as JSON. You will get the following output:
```json
Output
[ {
        "dst": "default",
        "gateway": "203.0.113.254",
        "dev": "eth0",
        "protocol": "static",
        "flags": [ ]
    } ]
```

You can now edit Suricata's configuration and verify or change the interface name. Use the following command:


```bash
sudo nano /etc/suricata/suricata.yaml
```
Drag the file to the af-packet: line, around line 580. If you are using nano, you can type CTRL+_ and enter the line number. Below line 580 is the default interface that Suricata uses to inspect traffic. Edit eth0 to match the interface as shown in the following example IPS/IDS Inline Mode, or see [AF_PACKET IPS mode](https://docs.suricata.io/en/latest/setting-up-ipsinline-for-linux.html#af-packet-ips-mode) for more details:
```yaml
af-packet:
  - interface: eth0
    threads: 1
    defrag: no
    cluster-type: cluster_flow
    cluster-id: 98
    copy-mode: ips
    copy-iface: eth1
    buffer-size: 64535
  - interface: eth1
    threads: 1
    cluster-id: 97
    defrag: no
    cluster-type: cluster_flow
    copy-mode: ips
    copy-iface: eth0
    buffer-size: 64535
```

# Step 3: Update of the Suricata Rules
```bash
sudo suricata-update
sudo suricata-update list-sources
```

# Step 4: Verify Suricata configuration
```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```

# Start Suricata (Inline) Mode:
```bash
sudo systemctl start suricata.service
sudo systemctl status suricata.service
```