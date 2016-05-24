#!/bin/bash
groupadd -f -g 112747 hoj9
useradd -u 112747 -g hoj9 hoj9
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su - hoj9
