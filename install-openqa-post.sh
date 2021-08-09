#!/bin/bash

set -e

do_fedora=0
do_rocky=1

if [[ do_fedora -eq 1 ]]; then
  if [[ ! -d /var/lib/openqa/tests/fedora ]]; then
    cd /var/lib/openqa/tests/
    sudo git clone https://pagure.io/fedora-qa/os-autoinst-distri-fedora.git fedora
    sudo chown -R geekotest:geekotest fedora
    cd fedora
    sudo ./fifloader.py -l -c templates.fif.json templates-updates.fif.json
  fi

  if [[ ! -d /var/lib/openqa/factory/hdd/fixed ]]; then
    sudo git clone https://pagure.io/fedora-qa/createhdds.git /root/createhdds
    sudo mkdir -p /var/lib/openqa/factory/hdd/fixed
    sudo mkdir -p /var/lib/openqa/factory/iso

    cd /var/lib/openqa/factory/hdd/fixed
    #sudo /root/createhdds/createhdds.py all
    find . -exec sudo chown geekotest '{}' \;
  fi

  echo Now clone a job from Fedora Project :-\)
  sudo openqa-clone-job --from https://openqa.fedoraproject.org/tests/943196
fi

if [[ do_rocky -eq 1 ]]; then
  basedir=/data
  if [[ ! -d /var/lib/openqa/tests/rocky ]]; then
    sudo mkdir -p /var/lib/openqa/tests/rocky
    (cd "${basedir}/os-autoinst-distri-rocky"; tar -cf - ./*) | (cd /var/lib/openqa/tests/rocky; sudo tar -xf -)
    cd /var/lib/openqa/tests
    sudo chown -R geekotest:geekotest rocky
    cd rocky
    sudo ./fifloader-rocky.py -l -c templates.fif.json
  fi

  sudo mkdir -p /var/lib/openqa/share/factory/iso
  sudo rsync --size-only --verbose "${basedir}/factory/iso/Rocky-8.4-x86_64-boot.iso" /var/lib/openqa/share/factory/iso/
  sudo rsync --size-only --verbose "${basedir}/factory/iso/Rocky-8.4-x86_64-minimal.iso" /var/lib/openqa/share/factory/iso/
  sudo rsync --size-only --verbose "${basedir}/factory/iso/Rocky-8.4-x86_64-dvd1.iso" /var/lib/openqa/share/factory/iso/

  if [[ 0 -eq 1 ]]; then
    echo Now post a new job for Rocky :-\)
    sudo openqa-cli api -X POST isos \
      ISO=Rocky-8.4-x86_64-minimal.iso \
      DISTRI=rocky \
      VERSION=GreenObsidian \
      FLAVOR=Server-dvd-iso \
      ARCH=x86_64 \
      GRUB="ip=dhcp bootdev=52:54:00:12:34:56 inst.waitfornet=300" \
      SUBVARIANT=Server

    # NOTE: Rocky boots without network interface ON, the GRUB option above enables the interface identified by the
    #       specified MAC (this is the qemu default for openQA) and allows the guest to have it's IP configured
    #       by qemu user networking.

    #sudo openqa-cli api -X POST isos \
    #  ISO=Rocky-8.4-x86_64-dvd1.iso \
    #  DISTRI=Rocky \
    #  VERSION=8.4 \
    #  FLAVOR=dvd-iso \
    #  ARCH=x86_64 \
    #  QEMU_HOST_IP=172.16.2.2 \
    #  NICTYPE_USER_OPTIONS="net=172.16.2.0/24" \
    #  _SKIP_POST_FAIL_HOOKS=1

    # sudo openqa-cli api -X POST isos \
    #  ISO=Rocky-8.4-x86_64-{boot,minimal,dvd1}.iso \
    #  DISTRI=Rocky \
    #  VERSION=green_obsidian \
    #  FLAVOR={server-iso,dvd-iso,generic_boot} \
    #  ARCH={x86_64,aarch64} \
    #  [BUILD={some_koji_build_id}]
  fi
fi

systemctl is-active openqa-worker@1 &> /dev/null
if [[ $? -eq 1 ]]; then
  sudo systemctl enable --now openqa-worker@1
fi
echo scheduled job should be started by worker!
