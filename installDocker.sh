#!/bin/bash
# install docker on Ubuntu 18.04

sudo apt update
sudo apt update -q

# install prerequisites
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# add key for docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add the repository to apt
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

sudo apt update

apt-cache policy docker-ce
sudo apt install docker-ce -y
# check if it is running
sudo systemctl status docker

# To later add an user to run without sudo
#sudo usermod -aG docker ${USER}
#su - ${USER}
#id -nG