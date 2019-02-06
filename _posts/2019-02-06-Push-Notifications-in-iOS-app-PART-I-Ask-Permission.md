---
layout: post
title: Push Local Notifications in iOS app - PART I Ask Permission
cover: test.jpg
date:   2019-02-06 16:34:00
comments: true
disqus_category_id: PushNotificationsIniOSApp
categories: [iOS, User Notifications]
tags: [iOS, User Notificatios, Push Notifications, Local Notifications, Permission to Show Notifications]
---

This article only discuss about the `Asking Permission part for Local Notifications`. I will discuss the remain part & `Remote Notifications` part in the future article.

Here is the guide link from Apple document, if you have time, I would suggest to read it :blush:
User Notifications: https://developer.apple.com/documentation/usernotifications

User Notifications - Asking permission to use notifications: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications

Come back to the topic. I want to show you how it would work.

## Request Authorization

About pushing notifications, whether the local notifications or the remote notifications. Of course the first thing we need to do is to request user's authorization to show the notification messags.

The code is super simple:
```swift
let center = UNUserNotificationCenter.current()
// Request permission to display alerts and play sounds.
center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
    // Enable or disable features based on authorization.
    if granted, error == nil {
        ...
    } else {
        ...
    }
}
```

Just add this code where you want to request the authorization. Most of the time, we make the authorization reqeust when we launch the app. Depends on your app, you could also ask the permission in some customized Permission UI and trigger it by clicking the buttons.

But, there is one thing you need to pay attention is:
in iOS app, we will only show this default notification permission dialog `1` time.

:arrow_up: This means user will only have 1 chance to use this default dialog to set their promotion about pushing notifications.

Sometimes, people ask, if I want to show this dialog again, and make user to change their options, what should I do? Well, in this case, I have to say, maybe you could give a custom permision page for this part, and with a trigger button for requesting setting notifications. Once user click it, you could just redirect your app to `Apple Default Settings` page, and let user to change switch on or off for showing your app notifications. OR, there is a simple way, you just give them a dialog, and tell them, you should set/change your notification settings in the Apple Default Settings part. It is so easy, right?

## Check Current Settings

After user click `Allow` or `Not Allow`, apple help us to store this value. And we could directly retrieve it.

Before we starting scheduling the notifications, we should check if current settings status. And schedule the corresponding notifications.

Here is the example code:
```swift
let notificationCenter = UNUserNotificationCenter.current()
notificationCenter.getNotificationSettings { (settings) in
   // Do not schedule notifications if not authorized.
   guard settings.authorizationStatus == .authorized else {return}

   if settings.alertSetting == .enabled {
      // Schedule an alert-only notification.
	   self.myScheduleAlertNotification()
   }
   else {
      // Schedule a notification with a badge and sound.
      self.badgeAppAndPlaySound()
   }
}
```

This is the begining of pushing notifications. Just 3 minutes is enough for setting this. :tada:

Next I will introduce how to scheduling local notifications, let's try to push our own notifications together. :tada: