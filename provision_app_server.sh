#!/bin/bash

set -e

# install oracle java 1.8 dependencies
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update

# utils
sudo apt-get install -y unzip dnsmasq oracle-java8-installer wget

# install leiningen
curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > lein
chmod +x lein
sudo mkdir -p /usr/local/bin
sudo mv lein /usr/local/bin

# consul client agent
wget https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip
unzip consul_0.7.0_linux_amd64.zip
sudo mv consul /usr/local/bin

# dnsmasq for consul dns
sudo mkdir -p /etc/dnsmasq.d
echo server=/consul/127.0.0.1\#8600 | sudo tee /etc/dnsmasq.d/10-consul
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

