# OpenQA-Fedora-Installation
Code for the YouTube video

PART ONE install OpenQA on local VM and get the fist test running.

## Getting the code

- Since you are already looking at this README I assume you gave some basic knowledge about version control.
- Clone this repo in the Client VM
- Run ```sudo ./install-openqa.sh```
- Go to localhost using the browser and click login

### If you're sticking to the Fedora example...
- Run ```sudo ./install-openqa-post.sh```
- This takes longer! But after it completes should give out of the box test.

### If you want to build/test for Rocky...
- Run ```sudo ./install-openqa-post-rocky.sh``` 
- This takes longer! But after it completes should give out of the box test.


## References
- OpenQA project website https://open.qa
- os-autoinst https://github.com/os-autoinst/openQA
- OpenQA SUSE https://openqa.opensuse.org/
- OpenQA Fedora https://openqa.fedoraproject.org/
- Fedora direct installation Guide https://fedoraproject.org/wiki/OpenQA_direct_installation_guide
- Tutorial create tests Dan Cermak: https://www.youtube.com/watch?v=2zwU9_bV_zI and https://www.youtube.com/watch?v=_JvqVrBjmIU
