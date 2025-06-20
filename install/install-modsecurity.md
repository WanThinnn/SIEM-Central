

# Installing ModSecurity v3 with Nginx (Manual Build)

🎥 **See**: [YouTube Setup Guide](https://www.youtube.com/watch?v=478ku0_2LvI)


# Required Packages

```bash
apt install g++ flex bison curl apache2-dev doxygen libyajl-dev ssdeep \
liblua5.2-dev libgeoip-dev libtool dh-autoreconf libcurl4-gnutls-dev \
libxml2 libpcre++-dev libxml2-dev git liblmdb-dev libpkgconf3 lmdb-doc \
pkgconf zlib1g-dev libssl-dev -y
```


# Install ModSecurity

```bash
wget https://github.com/owasp-modsecurity/ModSecurity/releases/download/v3.0.14/modsecurity-v3.0.14.tar.gz
tar -xvzf modsecurity-v3.0.14.tar.gz
cd modsecurity-v3.0.14
./build.sh
./configure
make
make install
```


# Install ModSecurity-nginx Connector and Build Nginx

```bash
cd ~
git clone https://github.com/owasp-modsecurity/ModSecurity-nginx.git

wget https://nginx.org/download/nginx-1.28.0.tar.gz
tar xzf nginx-1.28.0.tar.gz

useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx

cd nginx-1.28.0
./configure --user=nginx --group=nginx \
  --with-pcre-jit --with-debug --with-compat \
  --with-http_ssl_module --with-http_realip_module \
  --add-dynamic-module=/root/ModSecurity-nginx \
  --http-log-path=/var/log/nginx/access.log \
  --error-log-path=/var/log/nginx/error.log

make
make modules
make install

ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/
nginx -V
```


# Configuration Files

```bash
cp ~/modsecurity-v3.0.14/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
cp ~/modsecurity-v3.0.14/unicode.mapping /usr/local/nginx/conf/
cp /usr/local/nginx/conf/nginx.conf{,.bak}
```

# Hosts File Configuration

**Client Machine**

```bash
nano /etc/hosts
192.168.85.111 dvwa.local    # IP of ModSecurity server
```

**ModSecurity Server**

```bash
nano /etc/hosts
192.168.85.112 dvwa.local    # IP of DVWA machine
```


# Nginx Configuration Example

```nginx
load_module modules/ngx_http_modsecurity_module.so;
user nginx;
worker_processes 1;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80;
        server_name dvwa.local;

        modsecurity on;
        modsecurity_rules_file /usr/local/nginx/conf/modsecurity.conf;

        access_log /var/log/nginx/access_example.log;
        error_log /var/log/nginx/error_example.log;

        location / {
            proxy_pass http://192.168.85.112/dvwa/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root html;
        }
    }
}
```

# Enable ModSecurity Core Rule Set (CRS)

```bash
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /usr/local/nginx/conf/modsecurity.conf

git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/local/nginx/conf/owasp-crs
cp /usr/local/nginx/conf/owasp-crs/crs-setup.conf{.example,}

echo -e "Include owasp-crs/crs-setup.conf\nInclude owasp-crs/rules/*.conf" >> /usr/local/nginx/conf/modsecurity.conf
```



# Create systemd Service for Nginx

```bash
nano /etc/systemd/system/nginx.service
```

Paste the following:

```ini
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
```


# Start and Verify

```bash
systemctl daemon-reload
systemctl start nginx
systemctl enable nginx
systemctl status nginx
```

---

# Test ModSecurity

```bash
curl http://localhost?doc=/bin/ls
```

Expected response:

```html
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.20.2</center>
</body>
</html>
```

Check ModSecurity logs:

```bash
tail /var/log/modsec_audit.log
```
