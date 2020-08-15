---
layout: post
title: Exposure Notification for COVID-19
date: 2020-04-30 13:40:00
comment_id: 81
categories: [Developer]
tags: [iOS13.5, ExposureNotification]
---

## Overview

Apple release iOS 13.5 beta at 2020/04/29 and they also include the exposure notification API in this version.

> Across the world, governments, and health authorities are working together to find solutions to the COVID‑19 pandemic, to protect people and get society back up and running. Software developers are contributing by crafting technical tools to help combat the virus and save lives. In this spirit of collaboration, Google and Apple are announcing a joint effort to enable the use of Bluetooth technology to help governments and health agencies reduce the spread of the virus, with user privacy and security central to the design.

According to their document, they want to use this API to help tracking virus route and alerting people the possible exposure things.

Here is the basic idea of this API:
![narcexposure_notificationissistic](/images/2020-04-30-Exposure-Notification-for-COVID-19/exposure_notification.png)

## How we might use it

User might could enable it in the `Settings -> Privacy -> Health -> COVID-19 Exposure Notification`, then toggle it.

After user enable it, users' devices will regularly send out a beacon via Bluetooth which includes a privacy-preserving identifier. Other phones will listening for these beacons and broadcasting theirs as well. Once each phone receives another beacon, it will record and securely store that beacon on the device.

At least once per day, system will download the list of beacons which verified people who confirmed as positive for COVID-19 from relevant public health authority. Then each device will check the list of beacons it has recorded against the list downloaded from the server. If there is a match, user maybe notified and advised on steps to take next(ex: stay home).

This plan contains 2 phases:
1. companies release application programming interfaces(APIs) taht allow contact tracing apps from public health authorities to work across Android & iOS devices. These apps from public health authorities will be available for user to download via their respective app stores. Once app launched, user need to consent to the terms and conditions before the program is active. Companies plan to make these APIs available in May.
2. Operating system level to help ensure broad adoption. After operating system update is installed and user has opted in, system will send out and listen for the Bluetooth beacons as in the first place, without requiring an app to be installed. If a match is detected the user will be notified, and if the user has not already downloaded an official app they will be prompted to download an official app and advised on next steps. `Only public health authorities` will have access to this technology and their apps must meet specific criteria around privacy, security and data control.

#### Reference

<https://www.apple.com/covid19/contacttracing/#apl>

<https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ExposureNotification-FrameworkDocumentationv1.2.pdf>