# KRT-MN-INSTALL

unoffical but working explorer: http://46.101.190.123:3001/

Installscript for Kreita Masternodes, written by Kurbz and modified by Moondust2010
because the MN dont sync in the original Script and the offical Explorer stuck sometimes.

This guide covers only the VPS setup. I hope you know how to setup the Collateral.

If you need a VPS Service, please check out: https://www.vultr.com/?ref=7443282
5$ VPS are the best choice !

Your Wallet on your home PC / Laptop should be configured with relevant MNs setup and ready to start.

Run on Ubuntu 16.04 only.

Have your private key already generated from your local wallet, you need to have 1 key per MN you are running.

You can generate one by opening the console on your wallet and type:
````
---> masternode genkey
````
on your vps log in as root and run:
````
---->  bash <( curl https://raw.githubusercontent.com/moondust2010/KRT-MN-INSTALL/master/krt-install.sh )
````
Some in script instructions will ask you for the:

IP - this is auto filled

Private Key - this is you key you generated from 'masternode genkey' command on your wallet.

At the end of the script it will start to sync automatically, it will display the syncing block number.

You can find the current block number in your wallet info.

When block count = current block leave the script running and Goto your wallet and start the relevant MN.

* (If you notice you get stuck on a block, reboot the vps, log back in and run 'krtd getblockcount' until syncd then send start from local wallet) The script will automatically exit when the start trigger hits the vps..

* (if it does not exit then there is an issue, hit CTRL+C on the vps and check your status as below) to double confirm, or check status on your vps, run:
````
----> krtcli masternode status
````
You should receive a status 4 reply, your done!!.

* If not talk to discord channel support. https://discord.gg/Zepf4Bb

Commands on your Linux VPS Console:

stop the daemon:
````
krtcli stop
````
Checking Blocksync:
````
krtcli getinfo
````
open the Conf File:
````
nano /root/.krt/krt.conf
````
Start of krtd Daemon:
````
sudo systemctl start krtd
````
Masternode Status:
````
krtcli masternode status
````
