###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

BXCQ_DIR=/app/bxcq
BXCQ2_DIR=/var/www/bxcq

mkdir -p ${BXCQ_DIR}
wget --no-check-certificate https://github.com/minlearn/bxcq/raw/master/server.tar.gz -O /tmp/server.tar.gz
tar -xzf /tmp/server.tar.gz -C /lib/x86_64-linux-gnu server/libmysqlclient.so.16 --strip-components=1
tar -xzf /tmp/server.tar.gz -C ${BXCQ_DIR} --strip-components=1
rm -rf /tmp/server.tar.gz

silent apt-get -y install default-mysql-client
#if [[ ! -f /app/bxcq/_db/inited ]]; then
  #(cd /app/bxcq/_db;sudo bash db.sh;sudo touch /app/bxcq/_db/inited)
#fi


# Install Apache, PHP, and necessary PHP extensions
echo "Installing Apache and PHP..."
silent apt-get install -y apache2 libapache2-mod-php php-gd php-sqlite3 php-mysql php-mbstring php-xml php-zip

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
