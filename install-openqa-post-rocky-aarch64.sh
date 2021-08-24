#!/bin/bash

set -e

if [[ ! -d /var/lib/openqa/tests/rocky ]]; then
  echo "Run install-openqa-post-rocky.sh first"
  exit 1
fi

sudo mkdir -p /var/lib/openqa/share/factory/iso/fixed
if [[ ! -f /var/lib/openqa/share/factory/iso/fixed/CHECKSUM_aarch64 ]]; then
  cd /var/lib/openqa/share/factory/iso/fixed
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/aarch64/Rocky-8.4-aarch64-boot.iso
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/aarch64/Rocky-8.4-aarch64-minimal.iso
  sudo curl -C - -O download.rockylinux.org/pub/rocky/8/isos/aarch64/Rocky-8.4-aarch64-dvd1.iso
  sudo curl -C - download.rockylinux.org/pub/rocky/8/isos/aarch64/CHECKSUM  -o CHECKSUM_aarch64
  shasum -a 256 --ignore-missing -c CHECKSUM_aarch64
fi
