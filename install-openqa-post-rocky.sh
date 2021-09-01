#!/bin/bash

set -e

if [[ ! -d /var/lib/openqa/tests/rocky ]]; then
  cd /var/lib/openqa/tests/
  sudo git clone https://github.com/rocky-linux/os-autoinst-distri-rocky.git rocky
  sudo chown -R geekotest:geekotest rocky
  cd rocky
  sudo git checkout develop
fi
cd /var/lib/openqa/tests/rocky && sudo ./fifloader.py -l -c templates.fif.json templates-updates.fif.json

sudo mkdir -p /var/lib/openqa/share/factory/iso/fixed
if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/CHECKSUM ]]; then
  cd /var/lib/openqa/share/factory/iso/fixed
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.4-x86_64-boot.iso
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.4-x86_64-minimal.iso
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.4-x86_64-dvd1.iso
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/x86_64/CHECKSUM
  shasum -a 256 --ignore-missing -c CHECKSUM
fi

echo Now post a new job for Rocky :-\)
sudo openqa-cli api -X POST isos \
  ISO=Rocky-8.4-x86_64-minimal.iso \
  ARCH=x86_64 \
  DISTRI=rocky \
  FLAVOR=minimal-iso \
  VERSION=8.4 \
  BUILD="$(date +%Y%m%d.%H%M%S).0"

if ! systemctl is-active openqa-worker@1 &> /dev/null; then
  sudo systemctl enable --now openqa-worker@1
fi

echo Scheduled job should be started by worker!

echo Here is the jobs overview provided by openqa-cli api...
echo "openqa-cli api -X GET --pretty jobs/overview"
openqa-cli api -X GET --pretty jobs/overview

echo Here is the job detail for the first job...
echo "openqa-cli api -X GET --pretty jobs/1"
openqa-cli api -X GET --pretty jobs/1
