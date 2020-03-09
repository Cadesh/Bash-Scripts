#!/bin/bash
# Run this script as SUDO: sudo bash <scriptname.sh>
echo -e "\e[96mREDIS INSTALLATION SCRIPT\e[39m"

apt-get update
apt-get install build-essential tcl -y
cd /tmp

echo -e "\e[96mDownload latest version of Redis\e[39m"
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable

echo -e "\e[96mCompile redis binaries\e[39m"
make
make test

echo -e "\e[96mInstall and Configure Redis\e[39m"
make install
# configure redis
mkdir /etc/redis

# create configuration file
# to check default configuration file
# sudo cp /tmp/redis-stable/redis.conf 
echo "
bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised systemd
pidfile /var/run/redis_6379.pid
loglevel notice
logfile \"\"
databases 16
always-show-logo yes

save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no

repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no

replica-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly no
appendfilename \"appendonly.aof\"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events \"\"
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000

stream-node-max-bytes 4096
stream-node-max-entries 100

activerehashing yes

client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60

hz 10

dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
" >> /etc/redis/redis.conf
echo

# create redis unit file
echo "
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/redis.service
echo

# create redis admin user, group and give ownership to redis
adduser --system --group --no-create-home redis
mkdir /var/lib/redis
chown redis:redis /var/lib/redis
chmod 770 /var/lib/redis

echo -e "\e[96mStart Redis\e[39m"
systemctl start redis

# start redis automatically at restart
systemctl enable redis

# Node
echo -e "\e[96mINSTALL NODEJS v12 LATEST\e[39m"
sleep 1
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
echo -e "\e[96mINSTALL NPM LATEST\e[39m"
sleep 1
npm install npm@latest -g
echo

git clone https://github.com/Cadesh/telescope.git
cd telescope
npm install
cp feeds.txt src/backed/feeds.txt

echo -e "\e[96mScript Finished\e[39m"


# check if redis is running with
# systemctl status redis

# to run cli commands and try 'ping'
# redis-cli
# ping
# then 'exit'

# apt-get install redis-server
# sudo systemctl enable redis-server.service


# ANOTHER WAY TO INSTALL WITHOU COMPILING
# https://tecadmin.net/install-redis-ubuntu/
#sudo apt-get update
#sudo apt-get upgrade
#sudo apt-get install redis-server
#sudo systemctl enable redis-server.service
# change configuration file maxmemory 256mb maxmemory-policy allkeys-lru
#sudo systemctl restart redis-server.service