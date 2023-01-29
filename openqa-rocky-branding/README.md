# openqa-rocky-branding

## Reference

- [openQA branding documentation](https://github.com/os-autoinst/openQA/blob/master/docs/Branding.asciidoc)


## Clone Repository

```
# git clone https://github.com/rocky-linux/OpenQA-Fedora-Installation
# cd OpenQA-Fedora-Installation/openqa-rocky-branding
```


## Deploy Branding Content

A simple bash script is provided to deploy the content of this directory into your openQA instance

```
# ./deploy.sh
+ rsync -a ./usr/share/openqa/assets/images /usr/share/openqa/assets/
+ patch --backup --forward --verbose /usr/share/openqa/assets/assetpack.def usr/share/openqa/assets/assetpack.def.patch
./deploy.sh: line 11: patch: command not found
+ rsync -a ./usr/share/openqa/templates/webapi/branding/rocky /usr/share/openqa/templates/webapi/branding/
+ rpm -q patch
package patch is not installed
+ dnf -y install patch
Last metadata expiration check: 0:29:11 ago on Sun 29 Jan 2023 11:04:49 AM PST.
Dependencies resolved.
==================================================================================================================================
 Package                     Architecture                 Version                              Repository                    Size
==================================================================================================================================
Installing:
 patch                       x86_64                       2.7.6-17.fc37                        fedora                       124 k

Transaction Summary
==================================================================================================================================
Install  1 Package

Total download size: 124 k
Installed size: 247 k
Downloading Packages:
patch-2.7.6-17.fc37.x86_64.rpm                                                                    147 kB/s | 124 kB     00:00
----------------------------------------------------------------------------------------------------------------------------------
Total                                                                                              83 kB/s | 124 kB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                          1/1
  Installing       : patch-2.7.6-17.fc37.x86_64                                                                               1/1
  Running scriptlet: patch-2.7.6-17.fc37.x86_64                                                                               1/1
  Verifying        : patch-2.7.6-17.fc37.x86_64                                                                               1/1

Installed:
  patch-2.7.6-17.fc37.x86_64

Complete!
+ patch --backup --forward --verbose /usr/share/openqa/templates/webapi/main/index.html.ep usr/share/openqa/templates/webapi/main/index.html.ep.patch
Hmm...  Looks like a unified diff to me...
The text leading up to this was:
--------------------------
|--- index.html.ep	2023-01-24 03:34:10.861205160 +0000
|+++ index.html.ep	2023-01-24 03:34:44.364110582 +0000
--------------------------
patching file /usr/share/openqa/templates/webapi/main/index.html.ep
Using Plan A...
Reversed (or previously applied) patch detected!  Skipping patch.
Hunk #1 ignored at 10.
1 out of 1 hunk ignored -- saving rejects to file /usr/share/openqa/templates/webapi/main/index.html.ep.rej
done
+ cp /etc/openqa/openqa.ini /etc/openqa/openqa.ini.orig
+ sed -i 's/#*branding *= *[a-zA-Z]*/branding = rocky/g' /etc/openqa/openqa.ini
+ systemctl restart openqa-webui.service
```

Enjoy!