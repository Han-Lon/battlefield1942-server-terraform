#!/bin/bash
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

# Set the serverContentCheck in serversettings.con to false. The content check can cause issues if you have ANY differences in your local installation (e.g. mods)
sed -i 's/game.serverContentCheck 1/game.serverContentCheck 0/' ~/serverfiles/mods/bf1942/settings/serversettings.con
EOF