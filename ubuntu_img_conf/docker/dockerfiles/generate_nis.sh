#!/bin/bash
# usage: generate_nis.sh > ${output file}

echo '# build: docker build -t ubuntu-nis -f ${output file from this script} .'
echo '# run  : docker run -ti --rm -u {Your nis id} -v /auto:/auto -v ~/${your nis id}:/home/${your nis id} -h ${container host name} ubuntu-nis'
echo "FROM ubuntu:14.10" 
echo ""

echo "MAINTAINER James Ho"
echo ""

# Set up Environment variables
echo "ENV GROUP_ID $(id -g)"
echo "ENV GROUP $(id -ng)"
echo "ENV USER_ID $(id -u)"
echo "ENV USER $(id -nu)"
echo 'ENV HOME /home/${USER}'
echo ""
echo 'RUN groupadd -f -g ${GROUP_ID} ${GROUP} && \'
echo '    useradd -u ${USER_ID} -g ${GROUP} ${USER} && \'
echo '    usermod -a -G ${GROUP_ID},100 ${USER} && \'
echo '    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \'
echo '    mkdir -p ${HOME}'
echo ""
echo 'CMD ["/bin/bash"]'
