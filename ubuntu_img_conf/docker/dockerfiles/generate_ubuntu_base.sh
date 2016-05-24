#!/bin/bash
# usage: ./generate_go_nis.sh > ${output file}
#
# copy files from container to host
# docker cp <containerId>:/file/path/within/container /host

echo '# auto:'
echo '# docker build -t ubuntu-base:14.10 -f Dockerfile.ubuntu-base .'
echo '# run_ubuntu_base ubuntu-base:14.10 ubuntu-base'
echo '#'
echo ""

echo 'FROM ubuntu:14.10'
echo 'MAINTAINER James Ho'
echo ""

echo '# get the needed packages/libs'
echo 'RUN apt-get update -y && apt-get install --no-install-recommends -y -q \'
echo '    openssh-client \'
echo '    curl \'
echo '    build-essential \'
echo '    bison \'
echo '    ca-certificates \'
echo '    git \'
echo '    mercurial \'
echo '    wget \'
echo '    vim-gnome \'
echo '    libpcap0.8-dev \'
echo '    firefox \'
echo '    graphviz \'
echo '    libc6-dbg \'
echo '    gdb'
echo ""

echo '# Add user'
echo "ENV GROUP_ID $(id -g)"
echo "ENV GROUP $(id -ng)"
echo "ENV USER_ID $(id -u)"
echo "ENV USER $(id -nu)"
echo 'ENV HOME /home/${USER}'
echo ""

echo 'RUN groupadd -f -g ${GROUP_ID} ${GROUP} && \'
echo '    useradd -u ${USER_ID} -g ${GROUP} ${USER} && \'
echo '    usermod -a -G 0,4,27,30,46,1000 ${USER} && \'
echo '    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \'
echo '    mkdir -p ${HOME}'
echo ""

echo '# copy my own files'
echo 'COPY .profile ${HOME}/.profile'
echo 'COPY .bashrc ${HOME}/.bashrc'
echo 'RUN chown -R ${USER}:${USER} ${HOME}'
echo ""

echo 'CMD ["/bin/bash"]'
