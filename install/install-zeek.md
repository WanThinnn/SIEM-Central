
# Installing and Configuring **Zeek** on Ubuntu 22.04

🔗 **Reference**: [HowtoForge Guide](https://www.howtoforge.com/how-to-install-zeek-network-security-monitoring-tool-on-ubuntu-22-04/)


# Prerequisites

* Ubuntu 22.04 server (≥ 2 GB RAM)
* Root privileges
* Internet access (for apt, curl, etc.)

# Step 1: Update & Install Dependencies

```bash
apt update -y
apt upgrade -y
apt install curl gnupg2 wget -y
```


# Step 2: Add Zeek Repository

```bash
curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/security_zeek.gpg

echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' | tee /etc/apt/sources.list.d/security:zeek.list

apt update -y
```


# Step 3: Install Zeek

```bash
apt install zeek -y
```

📨 During installation, select **“local only”** for mail configuration and provide the system hostname when prompted.


# Step 4: Add Zeek to System PATH

```bash
echo "export PATH=$PATH:/opt/zeek/bin" >> ~/.bashrc
source ~/.bashrc
```

Verify installation:

```bash
zeek --version
```


# Step 5: Configure Zeek Networks

Edit Zeek's network range config:

```bash
nano /opt/zeek/etc/networks.cfg
```

Add or confirm:

```
192.168.0.0/16    Private IP space
10.81.85.0/24     Attacker Lab
```


# Step 6: Configure Cluster Nodes

Edit cluster configuration:

```bash
nano /opt/zeek/etc/node.cfg
```

Comment default section:

```ini
#[zeek]
#type=standalone
#host=localhost
#interface=eth0
```

Append cluster config (replace `your-server-ip` with actual IP):

```ini
[zeek-logger]
type=logger
host=your-server-ip

[zeek-manager]
type=manager
host=your-server-ip

[zeek-proxy]
type=proxy
host=your-server-ip

[zeek-worker]
type=worker
host=your-server-ip
interface=eth0

[zeek-worker-lo]
type=worker
host=localhost
interface=lo
```


# Step 7: Deploy Zeek Cluster

Check config first:

```bash
zeekctl check
```

Then deploy:

```bash
zeekctl deploy
```

You’ll see output like:

```
starting ...
starting logger ...
starting manager ...
starting proxy ...
starting workers ...
```

# Step 8: Monitor Zeek Status

Check status of all components:

```bash
zeekctl status
```

Example output:

```
Name         Type    Host         Status   Pid     Started
zeek-logger  logger  192.168.85.15 running ...
...
```


# Step 9: Explore Log Files

Logs are stored at:

```bash
/opt/zeek/logs/current/
```

List them:

```bash
ls -l /opt/zeek/logs/current/
```

View real-time logs:

```bash
tail -f /opt/zeek/logs/current/conn.log
tail -f /opt/zeek/logs/current/cluster.log
```


# Zeek Output Examples

**Cluster Log (cluster.log):**

```
zeek-proxy	got hello from zeek-worker
zeek-manager	got hello from zeek-worker-lo
```

**Connection Log (conn.log):**

```
192.168.85.111	→	192.168.85.112	TCP	OTH
...
```


# Conclusion

You’ve successfully installed and configured **Zeek** as a distributed security monitoring tool. It is now ready to analyze network traffic and forward logs to your SIEM (e.g., ELK Stack).

> 💡 *Zeek logs are ideal for threat hunting, correlation with Suricata alerts, or mapping to MITRE ATT\&CK.*

> Want to enrich Zeek output with Logstash for Elastic SIEM? Let me know!
