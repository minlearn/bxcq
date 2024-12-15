###############

echo "Installing Dependencies"
apt-get install -y curl
apt-get install -y sudo
apt-get install -y mc
echo "Installed Dependencies"

BXCQ_DIR=/app/bxcq
BXCQ2_DIR=/var/www/bxcq

sudo mkdir -p ${BXCQ_DIR}
sudo wget --no-check-certificate https://github.com/minlearn/bxcq/raw/master/server.tar.gz -O /tmp/server.tar.gz
sudo tar -xzvf /tmp/server.tar.gz -C /lib/x86_64-linux-gnu server/libmysqlclient.so.16 --strip-components=1
sudo tar -xzvf /tmp/server.tar.gz -C ${BXCQ_DIR} --strip-components=1
sudo rm -rf /tmp/server.tar.gz

<<'BLOCK'
# Install Apache, PHP, and necessary PHP extensions
echo "Installing Apache and PHP..."
sudo apt install apache2 libapache2-mod-php php-gd php-sqlite3 php-mysql php-mbstring php-xml php-zip -y

# Enable Apache mods
sudo a2enmod rewrite

# Install bxcq
echo "Installing bxcq..."
sudo mkdir -p ${BXCQ2_DIR}
cd ${BXCQ2_DIR}/..
sudo wget https://bxcq.org/latest.tar.gz -O latest.tar.gz
sudo tar -xzf latest.tar.gz -C ${BXCQ2_DIR} --strip-components=1
sudo rm latest.tar.gz
sudo chown -R www-data:www-data ${BXCQ2_DIR}

# Configure Apache to serve bxcq
echo "Configuring Apache..."
BXCQ_CONF="/etc/apache2/sites-available/bxcq.conf"
echo "<VirtualHost *:80>
     ServerName localhost:80
     DocumentRoot ${BXCQ2_DIR}
     <Directory ${BXCQ2_DIR}/>
          Options FollowSymlinks
          AllowOverride All
          Require all granted
     </Directory>
    
     <Directory ${BXCQ2_DIR}/>
            RewriteEngine on
            RewriteBase /
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteRule ^(.*) index.php [PT,L]
    </Directory>
</VirtualHost>" | sudo tee $BXCQ_CONF


sudo a2ensite bxcq.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
BLOCK

echo "bxcq installation completed successfully!"
echo "You can access bxcq at: http://${DOMAIN_OR_IP}/"

echo "Cleaning up"
apt-get -y autoremove
apt-get -y autoclean
echo "Cleaned"

##############