---
layout: post
title: What's New in Managing Apple Devices
date: 2020-11-25 15:35:00
comment_id: 113
categories: [WWDC2020, iOS]
tags: [Universal Link, Alternate Mode, MDM]
---

# Automated Device Enrollment

- Requires Apple School Manager or Apple Business Manager
- AUtomatically enroll devices into MDM
- Enrollment Customization options
- Pre-fill macOS account name
- Streamline setup assistant for users

# Managed Mac Apps

- Apps can be removed by MDM command and on un-enrollment
- iOS-style managed app configuration and feedback are supported
- MDM can convert an un-managed app to managed
- Managed App conversion is not supported for user enrolled devices

## Prevent silent profile installs from command line

![](/images/2020-11-25-What's-New-in-Managing-Apple-Devices/prevent.png)

## macOS management changes

![](/images/2020-11-25-What's-New-in-Managing-Apple-Devices/macOS.png)

# VPN

- Full Tunnel: all traffic can flow through
- Split Tunnel: chooses which traffic can flow through it
- per-app VPN: only lets certain apps' data flow through it
- per-account VPN: choose which VPN the accounts should use

## Encrypted DNS

- configure encrypted DNS without configuring a VPN
- supports network extensions

## iOS and iPadOS management updates

![](/images/2020-11-25-What's-New-in-Managing-Apple-Devices/ios.png)

#### Reference

- <https://developer.apple.com/news/?id=dopmcbjk>
