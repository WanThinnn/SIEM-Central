

# Installing DVWA (Damn Vulnerable Web Application) on Ubuntu

🔗 **Reference:** [Vietnix Guide](https://vietnix.vn/cai-dat-dvwa-tren-linux/#buoc-3-cau-hinh-dvwa)

# Step 1: Install Web & Database Stack

```bash
sudo apt update
sudo apt install mysql-server
sudo apt install apache2
sudo apt install git -y
```


# Step 2: Clone DVWA Source Code

```bash
cd /var/www/html
sudo git clone https://github.com/digininja/DVWA.git
sudo mv DVWA/ dvwa/
sudo mv index.html abc.html  # Backup default Apache page
```


# Step 3: Install PHP & Configure DVWA

```bash
sudo apt install php -y

cd dvwa/config/
sudo mv config.inc.php.dist config.inc.php
```


# Step 4: Configure PHP Settings

Navigate to your installed PHP directory (`7.2` may vary):

```bash
cd /etc/php/7.2/apache2/
sudo nano php.ini
```

Then restart Apache:

```bash
sudo systemctl restart apache2.service
```


# Step 5: Install PHP Modules for DVWA

```bash
sudo apt install php7.2-gd
sudo apt install php7.2-mysql
```

*If your PHP version is different (e.g., 8.1), replace `php7.2-*` with your version.*


# Step 6: Set Permissions & Update Config

```bash
sudo chmod -R 777 /var/www/html/dvwa/

cd /var/www/html/dvwa/config/
sudo nano config.inc.php
```

Edit the following lines:

```php
$_DVWA[ 'db_user' ] = 'root';
$_DVWA[ 'db_password' ] = '';
```

---

# Step 7: Configure MySQL

```bash
sudo mysql -u root
```

Then run the following inside MySQL prompt:

```sql
USE mysql;
SELECT Host, User, plugin FROM mysql.user;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
FLUSH PRIVILEGES;
EXIT;
```


# Step 8: Initialize DVWA Database

1. Open a browser and go to:
   **http\://\[DVWA-IP]/dvwa/setup.php**

2. Click **“Create / Reset Database”**

3. Then, if needed, verify from terminal:

```bash
sudo mysql -u root
USE dvwa;
EXIT;
```


Now you can **log in to DVWA** with default credentials:

```
Username: admin
Password: password
```

You're ready to test WAFs (like ModSecurity), simulate attacks, and validate SIEM logging pipelines!

