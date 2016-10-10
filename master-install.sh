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
## Setup nomad

nomad_url="https://releases.hashicorp.com/nomad/0.4.1/nomad_0.4.1_linux_amd64.zip"
nomad_file_name=`basename $nomad_url`

dl "$nomad_url"

unzip "$nomad_file_name"
mv nomad /usr/local/bin/

mkdir -p /var/lib/nomad
mkdir -p /etc/nomad

rm "$nomad_file_name"

cat > server.hcl <<EOF
addresses {
    rpc  = "ADVERTISE_ADDR"
    serf = "ADVERTISE_ADDR"
}

advertise {
    http = "ADVERTISE_ADDR:4646"
    rpc  = "ADVERTISE_ADDR:4647"
    serf = "ADVERTISE_ADDR:4648"
}

bind_addr = "0.0.0.0"
data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

server {
    enabled = true
    bootstrap_expect = 3
}
EOF
sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" server.hcl
mv server.hcl /etc/nomad/server.hcl

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
## Setup consul

consul_url="https://releases.hashicorp.com/consul/0.7.0/consul_0.7.0_linux_amd64.zip"
consul_file_name=`basename $consul_url`

mkdir -p /var/lib/consul

dl "$consul_url"
unzip "$consul_file_name"
mv consul /usr/local/bin/consul
rm "$consul_file_name"

cat > consul.service <<'EOF'
[Unit]
Description=consul
Documentation=https://consul.io/docs/

[Service]
ExecStart=/usr/local/bin/consul agent \
  -advertise=ADVERTISE_ADDR \
  -bind=0.0.0.0 \
  -bootstrap-expect=3 \
  -client=0.0.0.0 \
  -data-dir=/var/lib/consul \
  -server \
  -ui
  
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" consul.service
mv consul.service /etc/systemd/system/consul.service
systemctl enable consul
systemctl start consul

# ----------------------------------------
## Setup Vault

vault_url="https://releases.hashicorp.com/vault/0.6.2/vault_0.6.2_linux_amd64.zip"
vault_file_name=`basename $vault_url`

dl "$vault_url"
unzip "$vault_file_name"
mv vault /usr/local/bin/vault
rm "$vault_file_name"

mkdir -p /etc/vault

cat > /etc/vault/vault.hcl <<'EOF'
backend "consul" {
  advertise_addr = "http://ADVERTISE_ADDR:8200"
  address = "127.0.0.1:8500"
  path = "vault"
}

listener "tcp" {
  address = "ADVERTISE_ADDR:8200"
  tls_disable = 1
}
EOF

sed -i "s/ADVERTISE_ADDR/${IP_ADDRESS}/" /etc/vault/vault.hcl

cat > /etc/systemd/system/vault.service <<'EOF'
[Unit]
Description=Vault
Documentation=https://vaultproject.io/docs/

[Service]
ExecStart=/usr/local/bin/vault server \
  -config /etc/vault/vault.hcl
  
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

systemctl enable vault
systemctl start vault

# ----------------------------------------
## Setup dnsmasq

mkdir -p /etc/dnsmasq.d
cat > /etc/dnsmasq.d/10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF

systemctl enable dnsmasq
systemctl start dnsmasq

reboot
