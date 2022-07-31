# Linux-Custom-MOTD
Linux MOTD for debian based distros
```
Programs needed to work:
  sudo apt install lolcat
  sudo apt install figlet
```

```
To use the custom motd you must place it in
```
>***/etc/profile.d*** 

```
You may need also to disable the orginal motd.
To do that open the terminal and run these commands
```

```
1. cd etc/
2. sudo chmod -x update-motd.d/*
or 
2. sudo chmod -x /etc/update-motd.d/*
3. sudo service ssh restart
4. exit
```
And now relogin in to the server the motd should be working.

If you want to edit the motd and make some quick tests if its working, just do ***sudo -i***.
Remember figlet and lolcat will not work unless you loggin back into the server.

Have fun!😋
