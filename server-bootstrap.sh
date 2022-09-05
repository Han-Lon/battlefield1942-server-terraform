#!/bin/bash
# Restore default APT repositories for Ubuntu 20.04 Focal -- per this SO thread https://askubuntu.com/a/1367041
#cat <<EOF | sudo tee /etc/apt/sources.list
#deb http://archive.ubuntu.com/ubuntu/ focal main universe multiverse restricted
#deb http://security.ubuntu.com/ubuntu/ focal-security main universe multiverse restricted
#deb http://archive.ubuntu.com/ubuntu/ focal-updates main universe multiverse restricted
#deb http://archive.ubuntu.com/ubuntu/ focal-backports main universe multiverse restricted
#
#deb-src http://archive.ubuntu.com/ubuntu/ focal main universe multiverse restricted
#deb-src http://security.ubuntu.com/ubuntu/ focal-security main universe multiverse restricted
#deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main universe multiverse restricted
#deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main universe multiverse restricted
#EOF

# TODO try this instead, might be better than the multiline above
add-apt-repository universe

export DEBIAN_FRONTEND=noninteractive
dpkg --add-architecture i386
apt-get update -y && apt-get -o "Dpkg::Options::=--force-confold" dist-upgrade -y --force-yes

apt-get install binutils jq lib32gcc1 lib32stdc++6 libncurses5:i386 libsdl2-2.0-0:i386 libtinfo5:i386 netcat unzip -y

useradd -p $(openssl passwd -crypt "${PASSWD}") -m -s /bin/bash bf1942server

sudo -u bf1942server -i << EOF

wget -O ~/linuxgsm.sh https://linuxgsm.sh \
&& chmod +x ~/linuxgsm.sh \
&& bash ~/linuxgsm.sh bf1942server \
&& /usr/bin/yes | ~/bf1942server install

EOF