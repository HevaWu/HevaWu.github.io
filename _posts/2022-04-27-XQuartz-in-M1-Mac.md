---
layout: post
title: XQuartz in M1 Mac
date: 2022-04-27 14:30:00
comment_id: 213
categories: [M1Mac]
---

## Install

1. Download and install [MacPorts](https://github.com/macports/macports-base/releases/), check if install successfully by `port version`
2. `sudo port install xorg`
3. download and install [XQuartz](https://www.xquartz.org/)
4. on Mac `sudo reboot` to reboot the machine

## Test

run `xeyes` to see if it show any guide.
In my case, it tell me to run `sudo apt install x11-apps`

## Troubleshooting

### 1. command not found: port

Add ⬇️ into bash/zshrc file

```s
export PATH="$PATH:/opt/local/bin"
```

#### References

- <https://appletoolbox.com/run-xquartz-m1-mac/>
