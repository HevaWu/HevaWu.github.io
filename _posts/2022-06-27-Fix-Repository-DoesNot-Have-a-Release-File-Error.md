---
layout: post
title: Fix Repository Doesn't Have a Release File Error
date: 2022-06-27 13:32:00
comment_id: 223
categories: [Ubuntu 18.04, Linux]
---

Sometimes, we got issue when run `sudo apt-get update`, and may be required to add 3rd party PPAs. And when we run to update software packages, may run into an error indicating added PPA does not have a release file.

The error will look like:

```sh
E: The repository 'http://ppa.launchpad.net/wine/wine-builds/ubuntu bionic Release' does not have a Release file.
```

In above example, my system shows issue is on `wine` builds. Since I'd like to update system first, I'd like to remove this PPA to quick solve the issue.

For remove this PPA from system, the command line solution is here:

```sh
sudo apt-add-repository --remove ppa:wine/wine-builds
```

And it will promp:

```sh
Press [ENTER] to conitnue or Ctrl-c to cancel removing it.
```

After press `ENTER`, it will remove this PPA, and when we run `sudo apt-get update` again, this issue should be solved.


#### Reference

- <https://www.linuxtechi.com/fix-repository-release-file-error-ubuntu/>
