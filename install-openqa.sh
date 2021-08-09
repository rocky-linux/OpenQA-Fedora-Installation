#!/bin/bash

set -e

# Test script based on installation guide from Fedora:
# https://fedoraproject.org/wiki/OpenQA_direct_installation_guide

release=$(uname -a)
export release
echo Installing OpenQA on Fedora
echo Running on: "$release"

pkgs=(git vim-enhanced openqa openqa-httpd openqa-worker fedora-messaging guestfs-tools libguestfs-xfs python3-fedfind python3-libguestfs libvirt-daemon-config-network virt-install withlock postgresql-server perl-REST-Client)
if ! rpm -q "${pkgs[@]}" &> /dev/null; then
  sudo dnf install -y "${pkgs[@]}"
else
  echo "openqa and all requirements installed."
fi

conf_count=$(find /etc/httpd/conf.d -name "openqa*.conf" | wc -l)
if [[ ${conf_count} -ne 2 ]]; then
  sudo cp /etc/httpd/conf.d/openqa.conf.template /etc/httpd/conf.d/openqa.conf
  sudo cp /etc/httpd/conf.d/openqa-ssl.conf.template /etc/httpd/conf.d/openqa-ssl.conf
else
  echo "apache conf files for openqa exist."
fi

if [[ ! -f /etc/openqa/openqa.ini.orig ]]; then
  sudo cp /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
  sudo touch -r /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
fi

sudo bash -c "cat >/etc/openqa/openqa.ini <<'EOF'
[global]
branding=plain
download_domains = rockylinux.org fedoraproject.org opensuse.org

[auth]
method = Fake
<<<<<<< Updated upstream
EOF

postgresql-setup --initdb

sudo systemctl enable --now postgresql
sudo systemctl enable --now httpd
sudo systemctl enable --now openqa-gru
sudo systemctl enable --now openqa-scheduler
sudo systemctl enable --now openqa-websockets
sudo systemctl enable --now openqa-webui
sudo systemctl enable --now fm-consumer@fedora_openqa_scheduler
sudo systemctl enable --now sshd

sudo firewall-cmd --add-port=80/tcp
sudo firewall-cmd --runtime-to-permanent
sudo setsebool -P httpd_can_network_connect 1
sudo systemctl restart httpd

echo Note! the api key will expire in one day after installation!

sudo cat << EOF >  /etc/openqa/client.conf
=======
EOF"

if ! systemctl is-active postgresql.service &> /dev/null; then
#ret=$?
#if [[ $ret -ne 0 ]]; then
  sudo postgresql-setup --initdb
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
fi

if ! systemctl is-active sshd.service &> /dev/null; then
#ret=$?
#if [[ $ret -ne 0 ]]; then
  sudo systemctl start sshd
  sudo systemctl enable sshd
fi

systemctl is-active httpd.service &> /dev/null
ret=$?
if [[ $ret -ne 0 ]]; then
  sudo systemctl start httpd
  sudo systemctl start openqa-gru
  sudo systemctl start openqa-scheduler
  sudo systemctl start openqa-websockets
  sudo systemctl start openqa-webui
  sudo systemctl start fm-consumer@fedora_openqa_scheduler
  sudo systemctl enable httpd
  sudo systemctl enable openqa-gru
  sudo systemctl enable openqa-scheduler
  sudo systemctl enable openqa-websockets
  sudo systemctl enable openqa-webui
  sudo systemctl enable fm-consumer@fedora_openqa_scheduler
  sudo setsebool -P httpd_can_network_connect 1
  sudo systemctl restart httpd
fi

#sudo firewall-cmd --add-port=80/tcp
#sudo firewall-cmd --runtime-to-permanent

if sudo grep -q foo /etc/openqa/client.conf; then
  sudo bash -c "cat >/etc/openqa/client.conf <<'EOF'
>>>>>>> Stashed changes
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF"
  echo "Note! the api key will expire in one day after installation!"
fi

echo "Done, preparations. Now log in one time! Then run sudo ./install-openqa-post.sh"
