apt-get -y install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal
apt-get -y install ubuntu-gnome-desktop -y
apt-get -y install gnome-core xfce4 firefox
apt-get -y install vnc4server

# run '/usr/bin/vncpasswd' to setup passwd

# use lightdm for better performance

# dpkg -l | grep vnc
# sudo vncserver -kill :1
# system tools -> dconf Editor
#	org -> gnome -> desktop -> wm -> keybindings
#		maximize
#		panel-main-menu
#		show-desktop
#		unmaximize
