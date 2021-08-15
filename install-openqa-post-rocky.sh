#!/bin/bash

set -e

if [[ ! -d /var/lib/openqa/tests/rocky ]]; then
  cd /var/lib/openqa/tests/
  sudo git clone https://github.com/rocky-linux/os-autoinst-distri-rocky.git rocky
  sudo chown -R geekotest:geekotest rocky
  cd rocky
  sudo git checkout develop
  sudo ./fifloader.py -l -c templates.fif.json templates-updates.fif.json
fi

sudo mkdir -p /var/lib/openqa/share/factory/iso
if [[ ! -f /var/lib/openqa/share/factory/iso/CHECKSUM ]]; then
  cd /var/lib/openqa/share/factory/iso
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
  VERSION=8 \
  GRUB="ip=dhcp bootdev=52:54:00:12:34:56 inst.waitfornet=300"

if ! systemctl is-active openqa-worker@1 &> /dev/null; then
  sudo systemctl enable --now openqa-worker@1
fi

echo Scheduled job should be started by worker!


# NOTE: Rocky boots without network interface ON, the GRUB option above enables
#       the interface identified by the specified MAC (this is the qemu default
#       for openQA) and allows the guest to have it's IP configured by qemu
#       user networking.

#===============================================================================
# Additional samples...

# Install Server SUBVARIANT (triggers server-environment install)
#sudo openqa-cli api -X POST isos \
#  ISO=Rocky-8.4-x86_64-minimal.iso \
#  DISTRI=rocky \
#  VERSION=8
#  FLAVOR=dvd-iso \
#  ARCH=x86_64 \
#  GRUB="ip=dhcp bootdev=52:54:00:12:34:56 inst.waitfornet=300" \
#  PACKAGE_SET=server

# Change the network for the QEMU guest and disable post failure hooks to speed
# development

#sudo openqa-cli api -X POST isos \
#  ISO=Rocky-8.4-x86_64-dvd1.iso \
#  DISTRI=Rocky \
#  VERSION=8 \
#  FLAVOR=dvd-iso \
#  ARCH=x86_64 \
#  QEMU_HOST_IP=172.16.2.2 \
#  NICTYPE_USER_OPTIONS="net=172.16.2.0/24" \
#  _SKIP_POST_FAIL_HOOKS=1

# Change version to codename version_GreenObsidian_ident needle exists.
# FLAVOR generic_boot is currently untested/uninvestigated.

# sudo openqa-cli api -X POST isos \
#  ISO=Rocky-8.4-x86_64-{boot,minimal,dvd1}.iso \
#  DISTRI=Rocky \
#  VERSION=GreenObsidian \
#  FLAVOR={boot-iso,minimal-iso,dvd-iso,generic_boot} \
#  ARCH={x86_64,aarch64} \
#  [BUILD={some_koji_build_id}]
