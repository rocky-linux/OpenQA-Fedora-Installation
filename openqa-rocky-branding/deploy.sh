#!/bin/sh

set -x

# deploy images
rsync -a ./usr/share/openqa/assets/images /usr/share/openqa/assets/
# patch assetpack.def
patch --backup --forward --verbose /usr/share/openqa/assets/assetpack.def usr/share/openqa/assets/assetpack.def.patch

# deploy rocky branding templates
rsync -a ./usr/share/openqa/templates/webapi/branding/rocky /usr/share/openqa/templates/webapi/branding/

# patch openQA index.html.ep template (requires install of patch package)
rpm -q patch || dnf -y install patch
patch --backup --forward --verbose /usr/share/openqa/templates/webapi/main/index.html.ep usr/share/openqa/templates/webapi/main/index.html.ep.patch

# backup / modify openqa.ini file
cp /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
sed -i 's/#*branding *= *[a-zA-Z]*/branding = rocky/g' /etc/openqa/openqa.ini

# restart openqa-webui.service
systemctl restart openqa-webui.service
