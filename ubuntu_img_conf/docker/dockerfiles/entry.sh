#!/bin/bash
groupadd -f -g {ID} hoj9
useradd -u {ID} -g hoj9 hoj9
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su - hoj9
