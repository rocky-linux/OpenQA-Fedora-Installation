#!/bin/bash

set -e

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

systemctl is-active openqa-worker@1 &> /dev/null
if [[ $? -eq 1 ]]; then
  sudo systemctl enable --now openqa-worker@1
fi

echo Scheduled job should be started by worker!
