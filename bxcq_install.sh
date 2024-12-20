###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc gnupg
echo "Installed Dependencies"

BXCQ_DIR=/app/bxcq
BXCQ2_DIR=/var/www/bxcq

mkdir -p ${BXCQ_DIR}
wget --no-check-certificate https://github.com/minlearn/bxcq/raw/master/server.tar.gz -O /tmp/server.tar.gz
tar -xzf /tmp/server.tar.gz -C /lib/x86_64-linux-gnu server/libmysqlclient.so.16 --strip-components=1
tar -xzf /tmp/server.tar.gz -C ${BXCQ_DIR} --strip-components=1
rm -rf /tmp/server.tar.gz

silent apt-get -y install default-mysql-client

# Install Apache, PHP, and necessary PHP extensions
echo "Installing Apache and PHP..."
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ bullseye main" >> /etc/apt/sources.list
silent apt-get update
silent apt-get install -y apache2 libapache2-mod-php5.6 php5.6-gd php5.6-sqlite3 php5.6-mysql php5.6-mbstring php5.6-xml php5.6-zip

# Enable Apache mods
a2enmod rewrite

echo "Installing bxcq..."
mkdir -p ${BXCQ2_DIR}
cd ${BXCQ2_DIR}/..
wget https://github.com/minlearn/bxcq/releases/download/initial/html.tar.xz -O html.tar.xz
tar -xJf html.tar.xz -C ${BXCQ2_DIR} --strip-components=1
rm html.tar.xz
chown -R www-data:www-data ${BXCQ2_DIR}

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

</VirtualHost>" | tee $BXCQ_CONF


a2ensite bxcq.conf
a2dissite 000-default.conf
systemctl restart apache2

echo "bxcq installation completed successfully!"
echo "You can access bxcq at: http://${DOMAIN_OR_IP}/"

echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############
