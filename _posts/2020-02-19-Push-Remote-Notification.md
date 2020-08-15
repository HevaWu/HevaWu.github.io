---
layout: post
title: Push Remote Notification
date: 2020-02-19 10:38:00
comment_id: 54
categories: [iOS]
tags: [Notification]
---

Here is some guide from Apple:

- <https://developer.apple.com/notifications/>
- <https://developer.apple.com/documentation/usernotifications/>
- <https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server>

## Overview

> Remote notifications (also known as push notifications) let you push small amounts of data to devices on which your app is installed, even when your app isn't running.

The delivery of remote notifications includes several key components:

- Your company's server (known as the provider server)
- Apple Push Notification service (APNs)
- The user's device
- Your app (running on the user's device).

Server will decide when you want to send notifications to the users. when it is time, you generate a request containing the notification data and unique identifier for user's device. By forward reqest to APNs, which handles the delivery of the notification to user's device. Based on the receipt of the notification, OS on user's device handles any user interactions and delivers the notification to the app.

## Main task list

- Register app with APNs
- Generate remote notification
- Manage connection to APNs using HTTP/2 and TLS. (Send notification request to APNs)
- POST request, and send requests over HTTP/2 connection
- For token based authentication, regenerate token periodically

### Register app with APNs

1. Enable Push Notifications Capability
2. Register app and retrieve app's device token
> In iOS and tvOS, call the registerForRemoteNotifications() method of UIApplication to request the device token. Upon successful registration, you receive the token in your app delegate’s application(_:didRegisterForRemoteNotificationsWithDeviceToken:) method.
>
> In macOS, call the registerForRemoteNotifications() method of NSApplication to request the device token. Upon successful registration, you receive the token in your app delegate’s application(_:didRegisterForRemoteNotificationsWithDeviceToken:) method.
>
> In watchOS, you don't register explicitly for remote notifications. The user’s iPhone automatically forwards remote notifications to the watchOS app at appropriate times.

```swift
func application(_ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions:
           [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   // Override point for customization after application launch.

   UIApplication.shared.registerForRemoteNotifications()
   return true
}

func application(_ application: UIApplication,
            didRegisterForRemoteNotificationsWithDeviceToken
                deviceToken: Data) {
   self.sendDeviceTokenToServer(data: deviceToken)
}

func application(_ application: UIApplication,
            didFailToRegisterForRemoteNotificationsWithError
                error: Error) {
   // Try again later.
}
```

**Note**
Never cache device tokens in local storage. APNs issues a new token when the user restores a device from a backup, when the user installs your app on a new device, and when the user reinstalls the operating system. If you ask the system to provide the token each time, you are guaranteed to get an up-to-date token.

### Generate a remote notification

> Remote notifications convey important information to the user in the form of a JSON payload. The payload specifies the types of user interactions (alert, sound, or badge) that you want performed, and includes any custom data your app needs to respond to the notification.
>
> A basic remote notification payload includes Apple-defined keys and their custom values. You may also add custom keys and values specific to your notifications. Apple Push Notification service (APNs) refuses a notification if the total size of its payload exceeds the following limits:
>
> - For Voice over Internet Protocol (VoIP) notifications, the maximum payload size is 5 KB (5120 bytes).
>
> - For all other remote notifications, the maximum payload size is 4 KB (4096 bytes).

For more details about the json payload format, please check [here](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)

### Send notification requests to APNs

The request must include:

- The JSON payload that you want to send
- The device token for the user’s device
- Request-header fields specifying how to deliver the notification
- For token-based authentication, your provider server’s current authentication token

For more details about server settings, please check [here](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)

## Establish a Trusted Connection to APNs

> Communication between your provider server and APNs must take place over a secure connection. Creating that connection requires installing a [GeoTrust Global CA root certificate](https://www.geotrust.com/resources/root_certificates/certificates/GeoTrust_Global_CA.pem) on each of your provider servers. If your provider server runs macOS, this root certificate is in the keychain by default. On other systems, you might need to install this certificate yourself. You can download this certificate from the [GeoTrust Root Certificates](https://www.geotrust.com/resources/root-certificates/) website.

To send notifications, your provider server must establish either token-based or certificate-based trust with APNs using HTTP/2 and TLS.

- [Establishing a Token-Based Connection to APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns)
- [Establishing a Certificate-Based Connection to APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns)

### Establish a Token-Based Connection to APNs

> `Token-based` authentication offers a stateless way to communicate with APNs. Stateless communication is `faster` than `certificate-based` communication because it does not require APNs to look up the certificate, or other information, related to your provider server

Advantages:

- You can use the same token from multiple provider servers.
- You can use one token to distribute notifications for all of your company’s apps.

`Token-based` requests are slightly larget than `Certificate-based` one because each request contains the token. You must also update & encrypt tokens at least once an hour using the provider token signing key that Apple provides you.

For how to obtain it, please check [here](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_token-based_connection_to_apns)

**NOTE**
If you suspect that your authentication token signing key has been compromised, revoke it and request a new one. (You revoke the key from your developer account on developer.apple.com in the same place where you created it.) For maximum security, close all of your existing HTTP/2 connections to APNs and establish new connections before making new requests.

For security, APNs requires you to refresh your token regularly. Refresh your token no more than once every 20 minutes and no less than once every 60 minutes. APNs rejects any request whose token contains a timestamp that is more than one hour old. Similarly, APNs reports an error if you recreate your tokens more than once every 20 minutes.

On your provider server, set up a recurring task to recreate your token with a current timestamp. Encrypt the token again and attach it to subsequent notification requests.

### Establish a Certificate-Based Connection to APNs

> With certificate-based authentication, you use a provider certificate to establish a secure connection between your provider server and APNs. Because trust is established at the server-level, individual notification requests contain only your payload and a device token.

For how to obtain it, please check [here](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns)

## What APNs Provides

- APNs manages an accredited, encrypted, and persistent IP connection to the user’s device.
- APNs can store and forward notifications for a device that is currently offline.
- APNs coalesces notifications with the same identifier.
