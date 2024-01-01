#!/bin/bash

set -e

if [[ ! -d /var/lib/openqa/tests/rocky ]]; then
  cd /var/lib/openqa/tests/
  sudo git clone https://github.com/rocky-linux/os-autoinst-distri-rocky.git rocky
  sudo chown -R geekotest:geekotest rocky
fi

# the rocky test area will be owned by and operated by geekotest user so deploy the
# generated API key
if [[ ! -d /var/lib/openqa/.config/openqa ]]; then
  sudo mkdir -p /var/lib/openqa/.config/openqa
  sudo cp /etc/openqa/client.conf /var/lib/openqa/.config/openqa/
  sudo chown geekotest /var/lib/openqa/.config/openqa/client.conf
fi

if [[ -d /var/lib/openqa/tests/rocky ]]; then
  cd /var/lib/openqa/tests/rocky
  sudo -u geekotest git checkout develop
  sudo -u geekotest ./fifloader.py -l -c templates.fif.json templates-updates.fif.json
fi

if [[ ! -d /var/lib/openqa/share/factory/iso/fixed ]]; then
  sudo mkdir -p /var/lib/openqa/share/factory/iso/fixed
fi

if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/CHECKSUM ]]; then
  cd /var/lib/openqa/share/factory/iso/fixed
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/CHECKSUM
  if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/Rocky-8.9-x86_64-boot.iso ]]; then
    #sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.9-x86_64-boot.iso
    echo "skipping boot_iso"
  fi
  if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/Rocky-8.9-x86_64-minimal.iso ]]; then
    sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.9-x86_64-minimal.iso
  fi
  if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/Rocky-8.9-x86_64-dvd1.iso ]]; then
    #sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.9-x86_64-dvd1.iso
    echo "skipping dvd_iso"
  fi
  shasum -a 256 --ignore-missing -c CHECKSUM
  sudo /bin/rm -f CHECKSUM
fi

echo Now post a new job for Rocky :-\)
sudo -u geekotest openqa-cli api -X POST isos \
  ISO=Rocky-8.9-x86_64-minimal.iso \
  ARCH=x86_64 \
  DISTRI=rocky \
  FLAVOR=minimal-iso \
  VERSION=8.9 \
  BUILD="$(date +%Y%m%d)-Rocky-8.9-x86_64.0" \
  TEST=install_minimal

echo Scheduled job should be started by worker!

echo Here is the jobs overview provided by openqa-cli api...
echo "openqa-cli api -X GET --pretty jobs/overview"
openqa-cli api -X GET --pretty jobs/overview

echo Here is the job detail for the first job...
echo "openqa-cli api -X GET --pretty jobs/1"
openqa-cli api -X GET --pretty jobs/1
