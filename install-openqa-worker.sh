#!/bin/bash

set -e

# Test script based on installation guide from Fedora:
# https://fedoraproject.org/wiki/OpenQA_direct_installation_guide

if [ -z "$1" ]; then
  echo "No argument supplied, please enter OpenQA Server fqdn, or if installing"
  echo "server and worker on a single node supply 'localhost'."
  exit 1
fi


release=$(uname -a)
export release
echo Installing OpenQA Worker on Fedora
echo Running on: "$release"

pkgs=(guestfs-tools libguestfs-xfs libvirt-daemon-config-network openqa-worker perl-REST-Client python3-libguestfs virt-install withlock)
if ! rpm -q "${pkgs[@]}" &> /dev/null; then
  sudo dnf install -y "${pkgs[@]}"
else
  echo "openqa and all requirements installed."
fi

# Open vnc port for 4 local worker clients
if ! ( sudo firewall-cmd --get-services | grep -q openqa-vnc ); then
  sudo firewall-cmd --permanent --new-service=openqa-vnc
  sudo firewall-cmd --permanent --service=openqa-vnc --add-port=5991-5999/tcp
  sudo firewall-cmd --permanent --add-service openqa-vnc
  sudo firewall-cmd --permanent --new-service=openqa-socket
  sudo firewall-cmd --permanent --service=openqa-socket --add-port=20000-20089/tcp
  sudo firewall-cmd --permanent --add-service openqa-socket
  sudo firewall-cmd --reload
fi

if sudo grep -q foo /etc/openqa/client.conf; then
  sudo bash -c "cat >/etc/openqa/client.conf <<'EOF'
[$1]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF"
  echo "Note! the api key will expire in one day after installation!"
fi

if ! sudo grep -q http://openqa.example.host /etc/openqa/workers.conf; then
  sudo bash -c "cat >/etc/openqa/workers.conf <<'EOF'
[global]
HOST = https://$1
EOF"
fi

if ! systemctl is-active openqa-worker@1.service &> /dev/null; then
  sudo systemctl enable --now openqa-worker@1.service
fi
