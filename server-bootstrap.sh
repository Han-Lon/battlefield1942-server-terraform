#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update -y && apt-get -o "Dpkg::Options::=--force-confold" dist-upgrade -y --force-yes

useradd -p $(openssl passwd -crypt ${PASSWD}) bf1942server

sudo -u bf1942server -i << EOF

wget -O ~/linuxgsm.sh https://linuxgsm.sh && chmod +x ~/linuxgsm.sh && bash ~/linuxgsm.sh bf1942server
~/bf1942server install
EOF