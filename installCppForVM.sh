#!/bin/bash
# setup ubuntu vm for c programming
# author: Andre Rosa
# date: 03FEB2020

apt update
apt install gcc -y
apt install g++ -y
apt install vim -y
apt install make
apt install net-tools
apt install openssh-server -y
apt update -q
apt upgrade -y
