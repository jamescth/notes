#!/bin/bash

### http://stackoverflow.com/questions/24308760/running-app-inside-docker-as-non-root-user
### http://www.yegor256.com/2014/08/29/docker-non-root.html
### http://ypereirareis.github.io/blog/2015/05/04/docker-with-shell-script-or-makefile/
### http://reventlov.com/advisories/using-the-docker-command-to-root-the-host
### VARIABLES

DOCKER_IMAGE='ubuntu:14.10'
CONTAINER_USERNAME=$(id -nu)
CONTAINER_GROUPNAME=$(id -ng)
HOMEDIR='/home/'$CONTAINER_USERNAME
GROUP_ID=$(id -g)
USER_ID=$(id -u)

### FUNCTIONS
# groupadd -f -g 112747 hoj9
# useradd -u 112747 -g hoj9 hoj9

create_user_cmd()
{
  echo \
    groupadd -f -g $GROUP_ID $CONTAINER_GROUPNAME '&&' \
    useradd -u $USER_ID -g $CONTAINER_GROUPNAME $CONTAINER_USERNAME '&&' \
    mkdir --parent $HOMEDIR '&&' \
    chown -R $CONTAINER_USERNAME:$CONTAINER_GROUPNAME $HOMEDIR
}

execute_as_cmd()
{
  echo \
    sudo -u $CONTAINER_USERNAME HOME=$HOMEDIR
}

full_container_cmd()
{
  echo "'$(create_user_cmd) && $(execute_as_cmd) $@'"
}

### MAIN

eval docker run \
    --rm=true \
    -ti \
    -v $(pwd):$HOMEDIR \
    -w $HOMEDIR \
    $DOCKER_IMAGE \
    /bin/bash -ci $(full_container_cmd $@)
