#!/bin/bash

set -e

# Test script based on installation guide from Fedora:
# https://fedoraproject.org/wiki/OpenQA_direct_installation_guide

release=$(uname -a)
export release
echo Installing OpenQA Server on Fedora
echo Running on: "$release"

pkgs=(git openqa openqa-httpd mod_ssl nfs-utils perl-REST-Client postgresql-server python3-jsonschema withlock)
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

# TODO configure openqa-ssl.conf
# enable and set ServerName
# enable SSLProtocol
# enable SSLCipherSuite
# Consideration use certbot
# enable and set SSLCertificateFile
# enable and set SSLCertificateKeyFile

if [[ ! -f /etc/openqa/openqa.ini.orig ]]; then
  sudo cp /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
  sudo touch -r /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
fi

sudo bash -c "cat >/etc/openqa/openqa.ini <<'EOF'
[global]
branding=plain
download_domains = rockylinux.org fedoraproject.org opensuse.org
recognized_referers = bugs.rockylinux.org git.rockylinux.org bugzilla.suse.com bugzilla.opensuse.org progress.opensuse.org github.com

[auth]
method = Fake
EOF"

if ! systemctl is-active postgresql.service &> /dev/null; then
  sudo postgresql-setup --initdb
  sudo systemctl enable --now postgresql
fi

if ! systemctl is-active sshd.service &> /dev/null; then
  sudo systemctl start sshd
  sudo systemctl enable sshd
fi

if ! systemctl is-active httpd.service &> /dev/null; then
  sudo systemctl enable --now httpd
  sudo systemctl enable --now openqa-gru
  sudo systemctl enable --now openqa-scheduler
  sudo systemctl enable --now openqa-websockets
  sudo systemctl enable --now openqa-webui
  sudo setsebool -P httpd_can_network_connect 1
  sudo systemctl restart httpd
fi

sudo firewall-cmd --permanent --add-service={http,https}
sudo firewall-cmd --reload

if sudo grep -q foo /etc/openqa/client.conf; then
  sudo bash -c "cat >/etc/openqa/client.conf <<'EOF'
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF"
  echo "Note! the api key will expire in one day after installation!"
fi

echo ""
echo "Done, server preparations. Now log in one time!"
echo ""
echo "   http://$(hostname -f)/"
echo ""
echo "Next setup a worker node by running the worker script on another node"
echo ""
echo "    ./install-openqa-worker.sh"
echo ""
echo "If you want to do the Fedora setup following the YouTube video then run..."
echo ""
echo "    ./install-openqa-post.sh"
echo ""
echo "If you want to do a similar setup but for Rocky Linux then run..."
echo ""
echo "    ./install-openqa-post-rocky.sh"
echo ""
echo "In either case you may be prompted again for your password for sudo."
echo ""
