# Notes on usage of OpenQA-Fedora-Installation repository

## Default Network Interface is not CONNECTED in Rocky Linux Installer

Rocky Linx boots into Anaconda without the network interface ON without
specifying some additional configuration parameters.

A number of options exist to provide network configuraiton.

- the `GRUB` option can enable the interface identified by the specified MAC
  and allows the guest to have it's IP configured by qemu user networking.
- the `ANACONDA_STATIC` option can be used to set a static IP in the default
  static subnet used for multi-node tests.
- the `os-autoinst-distri-rocky` repository is being modified to enable
  the network interface for DHCP and to configure it with a static IP.

## Job timeout

Depending on your test host the default _do_install_and_reboot.pm test may
not complete within it's configured timeout (30 minutes). If the default
test job fails while installing you can change the timeout value as shown
below...

```
[rocky@openqa-dev openqa-install]$ grep 'my $timeout' \
/var/lib/openqa/tests/rocky/tests/_do_install_and_reboot.pm
   my $timeout = 1800;

[rocky@openqa-dev openqa-install]$ sudo sed -i 's/my $timeout = 1800;/my $timeout = 3600;/' \
/var/lib/openqa/tests/rocky/tests/_do_install_and_reboot.pm
[sudo] password for rocky:

[rocky@openqa-dev openqa-install]$ grep 'my $timeout' \
/var/lib/openqa/tests/rocky/tests/_do_install_and_reboot.pm
   my $timeout = 3600;
```

Then, you can resubmit the job from the openQA web UI or from the command
line as follows...

```
[rocky@openqa-dev openqa-install]$ sudo openqa-clone-job --from localhost 1
downloading
http://localhost/tests/1/asset/iso/Rocky-8.4-x86_64-minimal.iso
to
/var/lib/openqa/factory/iso/Rocky-8.4-x86_64-minimal.iso
Created job #2: rocky-8-minimal-iso-x86_64-install_minimal@64bit -> http://localhost/t2
```

And you can get job information with the openqa-cli api...

```
[rocky@openqa-dev openqa-install]$ openqa-cli api jobs/2 | jq '.job.settings'{
 "ARCH": "x86_64",
 "ARCH_BASE_MACHINE": "64bit",
 "BACKEND": "qemu",
 "DISTRI": "rocky",
 "FLAVOR": "minimal-iso",
 "GRUB": "ip=dhcp bootdev=52:54:00:12:34:56 inst.waitfornet=300",
 "ISO": "Rocky-8.4-x86_64-minimal.iso",
 "MACHINE": "64bit",
 "NAME": "00000002-rocky-8-minimal-iso-x86_64-install_minimal@64bit",
 "PACKAGE_SET": "minimal",
 "PART_TABLE_TYPE": "mbr",
 "POSTINSTALL": "_collect_data",
 "QEMUCPU": "Nehalem",
 "QEMUCPUS": "2",
 "QEMURAM": "3072",
 "QEMUVGA": "virtio",
 "QEMU_VIRTIO_RNG": "1",
 "TEST": "install_minimal",
 "TEST_SUITE_NAME": "install_minimal",
 "TEST_TARGET": "ISO",
 "VERSION": "8",
 "WORKER_CLASS": "qemu_x86_64"
}
```


```
[rocky@openqa-dev openqa-install]$ openqa-cli api jobs/2 | jq '.job.state'
"running"
```

## Addition Example Jobs

### Install PACKAGE_SET=server

This will trigger selection of `Server` from the Software Selection spoke...

```
sudo openqa-cli api -X POST isos \
  ISO=Rocky-8.4-x86_64-dvd1.iso \
  DISTRI=rocky \
  VERSION=8
  FLAVOR=dvd-iso \
  ARCH=x86_64 \
  PACKAGE_SET=server
```

### Disable POST_FAIL hooks to speed development

```
sudo openqa-cli api -X POST isos \
  ISO=Rocky-8.4-x86_64-dvd1.iso \
  DISTRI=rocky \
  VERSION=8
  FLAVOR=dvd-iso \
  ARCH=x86_64 \
  PACKAGE_SET=server \
  _SKIP_POST_FAIL_HOOKS=1
```


### Static IP configuration

Change the network for the QEMU guest and disable post failure hooks to speed
development

```
sudo openqa-cli api -X POST isos \
  ISO=Rocky-8.4-x86_64-dvd1.iso \
  DISTRI=Rocky \
  VERSION=8 \
  FLAVOR=dvd-iso \
  ARCH=x86_64 \
  QEMU_HOST_IP=172.16.2.2 \
  NICTYPE_USER_OPTIONS="net=172.16.2.0/24"
```



### Possible Future... CODENAME

Change version to codename version_GreenObsidian_ident needle exists.

`FLAVOR` generic_boot is currently untested/uninvestigated.

```
sudo openqa-cli api -X POST isos \
  ISO=Rocky-8.4-x86_64-{boot,minimal,dvd1}.iso \
  DISTRI=Rocky \
  VERSION=GreenObsidian \
  FLAVOR={boot-iso,minimal-iso,dvd-iso,generic_boot} \
  ARCH={x86_64,aarch64} \
  [BUILD={some_koji_build_id}]
```
