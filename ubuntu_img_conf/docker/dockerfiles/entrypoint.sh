#!/bin/bash
### http://stackoverflow.com/questions/24308760/running-app-inside-docker-as-non-root-user
### http://www.yegor256.com/2014/08/29/docker-non-root.html
### http://ypereirareis.github.io/blog/2015/05/04/docker-with-shell-script-or-makefile/
### http://reventlov.com/advisories/using-the-docker-command-to-root-the-host
### VARIABLES

groupadd -f -g $GROUP_ID $GROUP
useradd -u $USER_ID -g $GROUP $USER
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su - $USER
