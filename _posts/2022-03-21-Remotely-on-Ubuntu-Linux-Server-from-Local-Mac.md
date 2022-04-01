---
layout: post
title: Remotely on Ubuntu Linux Server from Local Mac
date: 2022-03-21 16:50:00
comment_id: 206
categories: [Mac, Ubuntu, Linux]
---

## 1. Enable `ssh`

From both
```s
ssh username@hostname(ip address or domain name)

# enable ssh server on Ubuntu
sudo systemctl enable ssh

# start ssh services
sudo systemctl start ssh
# stop ssh services
sudo systemctl stop ssh
# restart ssh services
sudo systemctl restart ssh

# view ssh status
sudo systemctl status ssh

# disable and remove ssh servers
sudo systemctl stop ssh
sudo systemctl disable ssh
sudo apt-get remove openssh-server
```

some ssh settings on MacBook:

```s
# copy ssh ip_rsa from MacBook to Linux
ssh-copy-id -i ~/.ssh/id_rsa.pub user@host
```

### Troubleshooting:

**Linux warning `no ssh command`**

install it by

```s
sudo apt-get install openssh-client
sudo apt-get install openssh-server
```

**Firewall block ssh access**

- [enable ssh](https://www.cyberciti.biz/faq/howto-configure-setup-firewall-with-ufw-on-ubuntu-linux/) and open ssh port
- open ssh tcp port 22 using ufw firewall, `sudo ufw allow ssh`

## 2. GUI through XWindow forwarding

```s
# open GUI from remote server
# -X or -Y allow XWindows of GUI apps to be forwarded to local desktop
ssh -X username@hostname
# or
ssh -Y username@hostname
```

### NOTE:

- if server is in an internal network, need to first connect through VPN to ssh in

## 3. File transfer

- ftp use tools like FileZilla(connect server through `sftp` protocol, i.e. ftp via ssh)
- mount remote directory in the naive file manager with Mac Fusion

```md
- install Fuse for Mac
- `sshfs username@hostname:/remote/directory/path/local/mount/point`
- remote directory can be accessed using bookFinder
```

## 4. Terminal ssh with `screen`

Keep session alive despite lost connection, use `screen`.
Only supports pure terminal applications, not GUI applications

- official documentation: https://www.gnu.org/software/screen/
- quick guide https://www.rackaid.com/blog/linux-screen-tutorial-and-how-to/

## 5. GUI session via Xpra

Xpra is screen for X11.

```s
# install xpra command
sudo apt-get install xpra

# start session
local_client> xpra start ssh/username@hostname/100 --start=xterm
# `100` is identifier of session name, different user should use different identifiers and same user can start multiple sessions by specifying distinct identifiers, ex: 101, 5000
# `xterm` is GUI program to run on start, can start any other GUI program from xterm

# disconnect from a session
# press `ctrl+c`

# attach/return to previous session
local_client> xpra attach ssh/username@hostname/100

# check xpra sessions
remote_server> xpra list

# terminate all xpra sessions
remote_server> xpra stop

# specify dpi when start or attach a session, to avoid mismatched DPI between server and client
local_client> xpra attach ssh/username@hostname/100 --dip=96
```

More xpra related guide:

- <https://xpra.org>
- usage: <http://manpages.ubuntu.com/manpages/xenial/man1/xpra.1.html>

## 6. NoMachine connect

- <https://www.nomachine.com>

NOTE: install `XQuartz` program on Mac

#### References

- <https://medium.com/@summitkwan/guide-work-remotely-on-a-linux-server-from-local-mac-windows-f05cdc6db0e0#toc_21>
- <https://www.cyberciti.biz/faq/how-to-install-ssh-on-ubuntu-linux-using-apt-get/>
