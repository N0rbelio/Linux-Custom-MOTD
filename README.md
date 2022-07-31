# Linux-Custom-MOTD
Linux MOTD for debian based distros

Programs needed to work:
->  sudo apt install lolcat
->  sudo apt install figlet

To use the custom motd you must place it in /etc/profile.d, you may need also to disable the orginal motd
To do that open the terminal and run these commands
cd etc/
sudo chmod -x update-motd.d/*
or 
sudo chmod -x /etc/update-motd.d/*
sudo service ssh restart
exit

And now relogin in to the server the motd should be working.

If u want to edit the motd and make some quick tests if its working, just do sudo -i.
Remember figlet and lolcat will not work unless you loggin back into the server.
