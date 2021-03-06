#!/bin/bash
# video
# https://digitaloceancode.com/install-prometheus-and-grafana-on-digitalocean/
# https://github.com/Cadesh/prometheus-course/tree/master/scripts
# install Ubuntu
# https://grafana.com/docs/grafana/latest/installation/debian/
# docker
# https://grafana.com/docs/grafana/latest/installation/docker/
# login on localhost:3000 with user:admin password:admin

sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Alternatively you can add the beta repository, see in the table above
sudo add-apt-repository "deb https://packages.grafana.com/enterprise/deb stable main"

sudo apt-get update
sudo apt-get install grafana-enterprise

#start grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server

# set to restart at boot
sudo systemctl enable grafana-server.service
