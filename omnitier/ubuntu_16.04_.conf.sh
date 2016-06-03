#!/bin/bash
# sync ubuntu repositories
sudo apt-get update

# update all the packages
sudo apt-get -y upgrade

### Docker
## https://docs.docker.com/engine/installation/linux/ubuntulinux/
# get CA certificates
sudo apt-get install apt-transport-https ca-certificates

# get GPG key
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# create/verify if docker.list exists
sudo touch /etc/apt/sources.list.d/docker.list

# truncate it
sudo cat /dev/null >| /etc/apt/sources.list.d/docker.list

# add an entry to docker.list.  16.04 only
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" >> /etc/apt/sources.list.d/docker.list

# update APT package index
sudo apt-get update

# verify that APT is pulling from the right repository
apt-cache policy docker-engine

# make sure linux-image-extra is installed
sudo apt-get install linux-image-extra-$(uname -r)

######## 14.04 #######
# apparmor is required
# sudo apt-get install apparmor

# install Docker
sudo apt-get install docker-engine

sudo service docker start

sudo docker run hello-world

# create a docker group
sudo groupadd docker

# add your user to docker group
sudo usermod -aG docker ubuntu


#### upgrade Docker
# sudo apt-get upgrade docker-engine

#### uninstallation
# sudo apt-get purge docker-engine
#### docker packages and dependencies
# sudo apt-get autoremove --purge docker-engine
# rm -rf /var/lib/docker
