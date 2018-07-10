#Script by @Digital_Narrative based on "https://raw.githubusercontent.com/moondust2010/KRT-MN-INSTALL/master/krt-install.sh", from @Moondust2010

#!/bin/bash
clear

# Check if we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Check if we have enough memory
if [[ `free -m | awk '/^Mem:/{print $2}'` -lt 900 ]]; then
  echo "This installation requires at least 1GB of RAM.";
  exit 1
fi

# Check if we have enough disk space
if [[ `df -k --output=avail / | tail -n1` -lt 10485760 ]]; then
  echo "This installation requires at least 10GB of free disk space.";
  exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
yum install git dnsutils systemd -y > /dev/null 2>&1

# Check for systemd
#systemctl --version >/dev/null 2>&1 || { echo "systemd is required. Are you using Ubuntu 16.04?"  >&2; exit 1; }

# CHARS is used for the loading animation further down.
CHARS="/-\|"
EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`

clear


echo "
 |   +------------ MASTERNODE INSTALLER v1.1 ---------------------+  |
 |   KRT Installer by Kurbz modified by Moondust & Digital_Narrative |
 |   for CentOS 7.5 only                                             |
 +-------------------------------------------------------------------+
"

sleep 2

USER=root

USERHOME=`eval echo "~$USER"`

read -e -p "Server IP Address: " -i $EXTERNALIP -e IP
read -e -p "Masternode Private Key: " KEY


clear

# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# update packages and upgrade Ubuntu
echo "Installing dependencies..."
yum -qq update
yum -qq upgrade
yum -qq autoremove
yum -qq install wget htop unzip
yum install systemd -y
yum update 
yum -y install libdb++-dev 
yum -y install libboost-all-dev 
yum -y install libcrypto++-dev 
yum -y install libqrencode-dev 
yum -y install libminiupnpc-dev 
yum -y install libgmp-dev 
yum -y install libgmp3-dev 
yum -y install autoconf 
yum -y install autogen 
yum -y install automake 
yum -y install bsdmainutils 
yum -y install libzmq3-dev 
yum -y install libminiupnpc-dev 
yum -y install libevent-dev
add-apt-repository -y ppa:bitcoin/bitcoin
yum update
yum install -y libdb4.8-dev libdb4.8++-dev
yum -qq install aptitude
yum update


aptitude -y -q install fail2ban
service fail2ban restart
yum -qq install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 47047/tcp
yes | ufw enable


echo "

**********Installing deamon***********
"
sleep 2
wget  https://raw.githubusercontent.com/moondust2010/KRT/master/krtd-Linux64
wget https://raw.githubusercontent.com/moondust2010/KRT/master/krt-cli-Linux64
cp ./krtd-Linux64 /usr/local/bin/krtd
cp ./krt-cli-Linux64 /usr/local/bin/krtcli
cp ./krtd-Linux64 krtd
cp ./krt-cli-Linux64 krtcli

chmod +x /usr/local/bin/krtd
chmod +x ./krtd
chmod +x /usr/local/bin/krtcli
chmod +x ./krtcli
echo "
*********Configuring confs***********
"
sleep 2
mkdir $USERHOME/.krt

# Create hightemperature.conf
touch $USERHOME/.krt/krt.conf
cat > $USERHOME/.krt/krt.conf << EOL
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
rpcport=47048
port=47047
listen=1
server=1
daemon=1
listenonion=0
logtimestamps=1
maxconnections=256
externalip=${IP}
bind=${IP}:47047
masternodeaddr=${IP}
masternodeprivkey=${KEY}
masternode=1
addnode=80.240.30.195:47047
addnode=108.61.178.219:47047
addnode=45.77.54.232:47047
addnode=80.240.30.253:47047
addnode=167.99.132.101:47047
EOL
chmod 0600 $USERHOME/.krt/krt.conf
chown -R $USER:$USER $USERHOME/.krt

sleep 1

cat > /etc/systemd/system/krtd.service << EOL
[Unit]
Description=krtd
After=network.target
[Service]
Type=forking
User=${USER}
WorkingDirectory=${USERHOME}
ExecStart=/usr/local/bin/krtd -conf=${USERHOME}/.krt/krt.conf -datadir=${USERHOME}/.krt
ExecStop=/usr/local/bin/krtcli -conf=${USERHOME}/.krt/krt.conf -datadir=${USERHOME}/.krt stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL

chmod +x /usr/local/bin/krtd 
chmod +x /usr/local/bin/krtcli
sudo ln -s /usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0 /usr/lib/x86_64-linux-gnu/libboost_program_options.so.1.54.0
#start service
echo "
********Starting Service*************
"
sleep 3
sudo systemctl enable krtd
sudo systemctl start krtd
sudo systemctl start krtd.service

#clear

echo "Service Started... Press any key to continue. "

#clear

echo "Your masternode is syncing. Please wait for this process to finish. "

until su -c "krtcli startmasternode local false 2>/dev/null | grep 'successfully started' > /dev/null" $USER; do
  for (( i=0; i<${#CHARS}; i++ )); do
    sleep 5
    #echo -en "${CHARS:$i:1}" "\r"
    clear
    echo "Service Started. Your masternode is syncing. 
    When Current = Synced then select your MN in the local wallet and start it."
    echo "Current Block: "
    su -c "curl http://46.101.190.123:3001/api/getblockcount" $USER
    echo "
    Synced Blocks: "
    su -c "krtcli getblockcount" $USER
  done
done

su -c "/usr/local/bin/krtcli startmasternode local false" $USER

sleep 1
su -c "/usr/local/bin/krtcli masternode status" $USER
sleep 1
#clear
#su -c "/usr/local/bin/krtd masternode status" $USER
#sleep 5

echo "" && echo "Masternode setup completed." && echo ""