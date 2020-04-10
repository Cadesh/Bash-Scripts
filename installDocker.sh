#!/bin/bash
# install docker on Ubuntu 18.04
# to claan windows /r errors use:  sed -i 's/\r//' <scriptname>
apt update
apt update -q

# install prerequisites
apt install apt-transport-https ca-certificates curl software-properties-common -y

# add key for docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add the repository to apt
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

apt update

apt-cache policy docker-ce
apt install docker-ce -y
# check if it is running
systemctl status docker

# To later add an user to run without sudo
#sudo usermod -aG docker ${USER}
#su - ${USER}
#id -nG