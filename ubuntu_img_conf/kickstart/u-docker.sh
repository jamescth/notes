apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
sh -c "echo deb https://get.docker.io/ubuntu docker main \
> /etc/apt/sources.list.d/docker.list"
apt-get -y update
apt-get -y install lxc-docker

# probably reboot

# xhost +

# gpasswd -a james docker
# gpasswd -a hoj9 docker
