#!/bin/bash

export IP_ADDRESS=`ifconfig eth0 | grep "inet addr" | awk '{ print substr($2,6) }'`

# wget isn't working properly, it keeps on
# segfaulting inside the scripts...
function dl {
    curl "$1" --output `basename "$1"`
}

apt-get update
apt-get upgrade -y
apt-get install -y unzip dnsmasq

# ----------------------------------------
## Setup nomad (client)

nomad_url=https://releases.hashicorp.com/nomad/0.4.1/nomad_0.4.1_linux_amd64.zip
nomad_file_name=`basename $nomad_url`

dl "$nomad_url"
unzip "$nomad_file_name"
mv nomad /usr/local/bin/

mkdir -p /var/lib/nomad
mkdir -p /etc/nomad

rm "$nomad_file_name"

# terraform created a config file for us using templates
# this step will just move it into place
mv client.hcl /etc/nomad

cat > nomad.service <<'EOF'
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/

[Service]
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
mv nomad.service /etc/systemd/system/nomad.service

systemctl enable nomad
systemctl start nomad

# ----------------------------------------
## Setup dnsmasq

mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF

systemctl enable dnsmasq
systemctl start dnsmasq

reboot
