apt update:
  cmd.run

apt install -y  wireguard:
  cmd.run

/etc/wireguard/:
  file.directory

#creating a new path for both public and private keys 
/etc/wireguard/keys:
  file.directory

#creating the keys in mentioned path
wg genkey | tee /etc/wireguard/keys/server.key | wg pubkey | tee /etc/wireguard/keys/server.key.pub:
  cmd.run

#creating the configuration file without the key for wg0 / adjusting the file permissions to classified
/etc/wireguard/wg.txt:
  file.managed:
    - source: salt://wireguard/bin/wg0.conf
    - mode: 600

#merging the private key onto the wg0.conf file
head -c -1 -q /etc/wireguard/wg.txt /etc/wireguard/keys/server.key > /etc/wireguard/wg0.conf:
  cmd.run

#enabling wg0 on startup
systemctl enable wg-quick@wg0:
  cmd.run

wg-quick up wg0: 
  cmd.run

#printing out if wg0 up on state.apply results
wg show wg0:
  cmd.run

#enabling packet forwarding
/etc/sysctl.conf:
  file.managed:
    - source: salt://wireguard/bin/sysctl
    - mode: 600

#printing out above changes on system network configurations
sysctl -p:
  cmd.run

#opening port for wg0 and enabling firewall
ufw allow 51820/udp && ufw allow 22/tcp:
  cmd.run

ufw enable:
  cmd.run
