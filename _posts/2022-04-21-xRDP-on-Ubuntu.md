---
layout: post
title: xRDP on Ubuntu
date: 2022-04-21 13:58:00
comment_id: 211
categories: [Linux, M1Mac, Ubuntu]
tags: [xRDP, SSH]
---

[xRDP](http://xrdp.org/) is under open source remote desktop protocol server. It is powerful to build security connection between server and local.

I use it on my work, and here is my env:
- Ubuntu 18.0.4
- local PC: MacOS Monterey 12.2.1, M1 chip

## Install xRDP guide

Here is a good documentation which explain it: <http://c-nergy.be/blog/?p=14965>

I will only put all of commands at here:

```sh
cd ~/Downloads
wget http://www.c-nergy.be/downloads/xrdp-installer-1.2.zip
unzip xrdp-installer-1.2.zip
chmod +x xrdp-installer-1.2.sh
./xrdp-installer-1.2.sh

# on Ubuntu
sudo apt-get install openssh-server
sudo gedit /etc/xrdp/xrdp.ini

# change port=3389 to
port=tcp://.:3389

sudo systemctl restart xrdp

# configure from putty.exe
# Session: hostname, ip
# SSH node - Tunnel: source port 5555, destination localhost:3389
# prepare saved sessions name

# use
# ssh %user%@%servername-or-ip% -L %LocalPort%:127.0.0.1:%RemotePort%
```

## Troubleshooting

### 1. blank screen after input username and password

```sh
sudo apt-get install xorgxrdp-hwe-18.04
sudo apt-get install gnome-tweak-tool -y

sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

#Check if script has already run....
if grep -xq "#fixGDM-by-Griffon" /etc/xrdp/startwm.sh; then
 echo "Skip theme fixing as script has run at least once..."
else
#Set xRDP session Theme to Ambiance and Icon to Humanity
sudo sed -i.bak "4 a #fixGDM-by-Griffon\ngnome-shell-extension-tool -e ubuntu-appindicators@ubuntu.com\ngnome-shell-extension-tool -e ubuntu-dock@ubuntu.com\n\nif [ -f ~/.xrdp-fix-theme.txt ]; then\necho 'no action required'\nelse\ngsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'\ngsettings set org.gnome.desktop.interface icon-theme 'Humanity'\necho 'check file for xrdp theme fix' >~/.xrdp-fix-theme.txt\nfi\n" /etc/xrdp/startwm.sh
fi
```

OR

```sh
sudo apt-get install xorgxrdp -y
```

### 2. Authentication Required to Create Managed Color Device

Detail explanation is [at here](https://c-nergy.be/blog/?p=12073)

create a file (called 02-allow-colord.conf) in /etc/polkit-1/localauthority.conf.d/ and populated with the following content

```sh
polkit.addRule(function(action, subject) {
 if ((action.id == "org.freedesktop.color-manager.create-device" ||
 action.id == "org.freedesktop.color-manager.create-profile" ||
 action.id == "org.freedesktop.color-manager.delete-device" ||
 action.id == "org.freedesktop.color-manager.delete-profile" ||
 action.id == "org.freedesktop.color-manager.modify-device" ||
 action.id == "org.freedesktop.color-manager.modify-profile") &&
 subject.isInGroup("{users}")) {
 return polkit.Result.YES;
 }
 });
```

### 3. When putty display remote window, Ubuntu machine's display is not working (keyboard and mouse is locked)

Try ⬇️

```sh
sudo apt install xserver-xorg-input-all
```

Some discussion is at here: <https://askubuntu.com/questions/1348291/what-is-xserver-xorg-input-all-and-its-purpose>

### 4. Locale setting is wrong

on Mac, under `Terminal` -> `Preferences` -> `Advanced` -> turn off `Set locale environment variables on startup`

#### References

- <http://c-nergy.be/blog/?p=14965>
- <https://c-nergy.be/blog/?p=12073>
