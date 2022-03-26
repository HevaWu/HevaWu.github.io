---
layout: post
title: Fix sudo /etc/sudoers is owned by uid 502 Error
date: 2021-01-22 21:34:00
comment_id: 133
categories: [MacOS]
tags: [Command]
---

Previously I miss changed the `sudoers` file, and unfortunately `sudoers` file be locked. After that, I tried to copy `sudoers` and save it to original path. It start throw 502 error to me:

```s
sudo: /etc/sudoers is owned by uid 502, should be 0
sudo: no valid sudoers sources found, quitting
sudo: unable to initialize policy plugin
```

This is because after I copy `sudoers` and replace old file, the new file `missing` the `system` read authority. The correct file permissions should be:

![](/images/2021-01-22-Fix-sudo-etcsudoers-is-owned-by-uid-502-Error/auth.JPG)

## Final Solution

<https://apple.stackexchange.com/a/353478>

## Try Flow

Basically, I tried this page solutions: <https://apple.stackexchange.com/questions/157772/sudo-etc-sudoers-is-owned-by-uid-501-should-be-0>

The first I tried is: <https://apple.stackexchange.com/a/157775>, go into single user mode by `cmd+S`, and following this command:

```s
mount -uw /
chown root /etc/sudoers
chmod 440 /etc/sudoers
reboot
```

However, I stuck at `mount -uw /`, it shows me error like:

```s
Updating mount from `disk` to read/write mode is not allowed.
mount_apfs: volume could not be mounted: Operation not permitted
mount: / failed with 77
```

After searching, refering this link: <https://apple.stackexchange.com/a/401963I>, I got that this happen because in MacOS Catalina, System Integrity Protection(SIP) is active. We have to go into Recovery Mode to run the command.

OK.

- Hold `cmd+R`, go into recovery mode
- `Disk Utilities > Select Macintosh HD, and Mount` confirm disk is under Mount
- Close Disk Utilities
- NavigationBar: Utilities > Terminal
- Type: `chown root:wheel "/Volumes/Macintosh HD/etc/sudoers"`
- `reboot`

🎉 After computer restarted, tap `sudo su` to double check, and the error is disappeared now!!

#### Reference

- <https://apple.stackexchange.com/questions/157772/sudo-etc-sudoers-is-owned-by-uid-501-should-be-0>
- <https://apple.stackexchange.com/questions/401921/sbin-mount-uw-not-working>
