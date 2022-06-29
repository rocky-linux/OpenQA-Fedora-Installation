# OpenQA-Fedora-Installation

Code for the YouTube video

PART ONE install OpenQA on local VM and get the fist test running.

## Getting the code

- Since you are already looking at this README I assume you gave some basic knowledge about version control.
- Clone this repo in the Client VM
- Run `sudo ./install-openqa.sh`
- Go to localhost using the browser and click login

### If you're sticking to the Fedora example...

- Run `sudo ./install-openqa-post.sh`
- This takes longer! But after it completes should give out of the box test.

### If you want to build/test for Rocky...

- Run `sudo ./install-openqa-post-rocky.sh`
- This takes longer! But after it completes should give out of the box test.

## If you are trying to install a more advanced multi-server setup

- Clone this repo in the Server VM
- Run `sudo ./install-openqa-server.sh`
- If wanted generate a certificate and place it in the correct directories, like mentioned in the script
- Go to the FQDN of the server in your browser and click login
- Clone this repo in the (or one of the) Worker VM (it is possible to run this on the server as well)
- Run `sudo ./install-openqa-worker.sh <server-fqdn>`
- Make sure in the web frontend, that the worker appears and is in idle state
- After a successful testrun, make sure you generate a new API key pair and place it in `/etc/openqa/client.conf` on the server and workers

## References

- OpenQA project website https://open.qa
- os-autoinst https://github.com/os-autoinst/openQA
- OpenQA SUSE https://openqa.opensuse.org/
- OpenQA Fedora https://openqa.fedoraproject.org/
- Fedora direct installation Guide https://fedoraproject.org/wiki/OpenQA_direct_installation_guide
- Tutorial create tests Dan Cermak: https://www.youtube.com/watch?v=2zwU9_bV_zI and https://www.youtube.com/watch?v=_JvqVrBjmIU
