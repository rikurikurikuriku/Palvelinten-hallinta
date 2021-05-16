apt update:
  cmd.run

apt install -y  wireguard:
  cmd.run

/etc/wireguard/:
  file.directory

/etc/wireguard/keys:
  file.directory

wg genkey | tee /etc/wireguard/keys/server.key | wg pubkey | tee /etc/wireguard/keys/server.key.pub:
  cmd.run


/etc/wireguard/wg.txt:
  file.managed:
    - source: salt://wireguard/bin/wg0.conf
    - mode: 600

head -c -1 -q /etc/wireguard/wg.txt /etc/wireguard/keys/server.key > /etc/wireguard/wg0.conf:
  cmd.run

systemctl enable wg-quick@wg0:
  cmd.run

wg-quick up wg0: 
  cmd.run

wg show wg0:
  cmd.run

/etc/sysctl.conf:
  file.managed:
    - source: salt://wireguard/bin/sysctl
    - mode: 600
  
sysctl -p:
  cmd.run

ufw allow 51820/udp && ufw allow 22/tcp:
  cmd.run

ufw enable:
  cmd.run
