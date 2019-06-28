#!/bin/bash
# author: Cadesh
# JUNE 26, 2019
# objective: Script to install Bot Server
# THIS SCRIPT USES SELF-SIGNED SSL CERTIFICATES, THEREFORE THIS IS NOT MEANT FOR PRODUCTION
# IF YOU CHANGED THE FILE IN WINDOWS, USE THE COMMAND BELLOW BEFORE RUNNING THE SCRIPT
# sed -i 's/\r//' scriptname.sh 
# TO RUN THE SCRIPT USE A CLEAN D.O. SERVLET WITH UBUNTU 16.04.6 and SUDO POWERS
# sudo bash scriptname.sh
#---------------------------------------------------------------------------

# to avoid tty error
# https://superuser.com/questions/1160025/how-to-solve-ttyname-failed-inappropriate-ioctl-for-device-in-vagrant
sed -i -e 's/mesg n .*true/tty -s \&\& mesg n/g'

# GETS ARGUMENTS DOMAIN MUST BE IP, SECOND ARGUMENT IS CREATOR EMAIL

REPO='https://xxxx@bitbucket.org/xxxx/xxxxx.git' #
DOMAIN='xxxx.xxxx.com'
EMAIL='andre@xxxx.com'

IPNUM=$(hostname -I | awk '{print $1}') # captures the machine ip

echo -e "\e[96mINITIATE SCRIPT FOR MACHINE: $IPNUM\e[39m"
echo -e "\e[96mGIT REPOSITORY LOCATION: $REPO\e[39m"

#---------------------------------------------------------------------------
# CAPTURES THE NAME OF THE REPOSITORY FROM THE GIT URL (to use at the bottom)
basename=$(basename $REPO)
echo $basename
GITFOLDER=${basename%.*}
echo $GITFOLDER
#---------------------------------------------------------------------------

#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# INSTALL NGINX
echo -e "\e[96mSYSTEM UPDATE\e[39m"
sleep 2
apt-get update
echo -e "\e[96mINSTALL NGINX\e[39m"
apt-get install nginx -y
apt autoremove -y
ufw allow 'Nginx Full'
systemctl stop nginx
echo "DONE WITH NGINX"
sleep 2
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# CREATE SELF-SIGNED SSL CERTIFICATE
echo -e "\e[96mCREATE SSL CERTIFICATE AND KEY\e[39m"
sleep 2
# Certificate details
subj="
C=CA
ST=ON
O=Toronto
localityName=Toronto
commonName=$IPNUM
organizationalUnitName=xxxx.com
emailAddress=xxxx.com
"
# Generate the CSR
openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -subj "$(echo -n "$subj" | tr "\n" "/")" \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt
sleep 1

echo -e "\e[96mCREATE KEY\e[39m"
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
# CREATE SSL CONFIG FILE
echo -e "\e[96mCREATE SSL CONFIG FILE\e[39m"
echo "ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;" >> /etc/nginx/snippets/self-signed.conf
sleep 1
# CREATE SSL PARAM FILE
echo -e "\e[96mCREATE SSL PARAM FILE\e[39m"
echo "# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers \"EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH\";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the \"preload\" directive if you understand the implications.
#add_header Strict-Transport-Security \"max-age=63072000; includeSubdomains; preload\";
add_header Strict-Transport-Security \"max-age=63072000; includeSubdomains\";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
" >> /etc/nginx/snippets/ssl-params.conf

# SET NGINX TO USE THE CONFIGURATION FILES
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak 
rm -f /etc/nginx/sites-available/default
echo -e "\e[96mSAVE NEW CONFIGURATION FILE\e[39m"
sleep 2
echo "
server {

    location / {
        add_header 'Access-Control-Allow-Origin' "\$http_origin";
        add_header 'Access-Control-Allow-Credentials' 'true';
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Forwarded-For \$remote_addr;
    }

    server_name 68.183.194.83;

    # SSL configuration
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

}
server {
    listen 80;

    server_name $IPNUM;
    return 404; # managed by Certbot
}
" >> /etc/nginx/sites-available/default
echo
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# INSTALL ESSENTIALS - C++ MAKE
echo -e "\e[96mINSTALL UBUNTU ESSENTIALS (MAKE)\e[39m"
apt-get install build-essential -y
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# INSTALL NODEJS AND NPM
echo -e "\e[96mINSTALL NODEJS v10 LATEST\e[39m"
sleep 1
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get install -y nodejs
echo -e "\e[96mINSTALL NPM LATEST\e[39m"
sleep 1
npm install npm@latest -g
echo
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# INSTALL PM2
echo -e "\e[96mINSTALL PM2\e[39m"
sleep 2
npm install -g pm2
echo
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# INSTALLING MONGODB
echo -e "\e[96mINSTALL MONGODB\e[39m"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
apt-get update
apt-get install mongodb-org -y
systemctl start mongod
systemctl enable mongod 
echo
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
echo -e "\e[96mINSTALL GIT\e[39m"
sleep 2
apt-get install git
echo
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
# MOVE TO DESTINATION DIRECTORY
cd
cd ../var/www  # move to the code location
# DOWNLOAD THE BOT CODE FROM BITBUCKET
echo -e "\e[96mCLONING BITBUCKET REPO\e[39m"
git clone $REPO
sleep 2
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
#CREATE LOG FILE
cd
cd ../var/www/$GITFOLDER # move to the code folder
pwd
mkdir logs
touch logs/debug.log
#---------------------------------------------------------------------------
#
#---------------------------------------------------------------------------
echo -e "\e[96mINSTALL NATIVE-BOT DEPENDENCIES\e[39m"
npm install
echo
echo -e "\e[96mRUN NPM AUDIT FIX\e[39m"
npm audit fix
sleep 5
npm install debug
sleep 5
npm audit fix
#---------------------------------------------------------------------------

echo -e "\e[96mSTART APP\e[39m"
cd  # returns to root
pm2 start ../var/www/$GITFOLDER/app.js # start app
systemctl restart nginx # restart nginx

echo -e "\e[96mSTART FIREWALL\e[39m"
ufw allow 'Nginx Full' #allow niginx to bypass firewall
ufw allow ssh # allow ssh connection to bypass firewall
echo "y" | sudo ufw enable # activate firewall with 'yes'
ufw status

echo -e "\e[96mDONE! Now go to https://$IPNUM/api/init to check your bot welcome message\e[39m"

# #---------------------------------------------------------------------------
# #---------------------------------------------------------------------------