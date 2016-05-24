# base on go-nis:1.4.2

# cp vim setting
cp /root/.vim* /home/hoj9/
cp -r /root/.vim /home/hoj9
chown hoj9:hoj9 /home/hoj9/.vimrc
chown -R hoj9:hoj9 /home/hoj9/.vim

# save back
docker commit {container} go-nis:1.4.2
