---
layout: post
title: Try Flutter with Firebase Cloud Messaging
date: 2022-07-19 14:30:00
comment_id: 226
categories: [Dart]
tags: [Flutter, FCM]
---

# Setup Flutter Client

## iOS

- [Enable app capabilities in Xcode](https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=en#enable_app_capabilities_in_xcode)
  - open `ios/Runner.xcworkspace`
  - enable `Push Notification`
  - enable `Background Modes - Background Fetch, Remote notifications`
- Upload your APNs certificate
  - Apple Developer Account - Certificate - Create APNs Certificate
    - [Create CSR](https://help.apple.com/developer-account/#/devbfa00fef7) from local
    - NOTE: need to create `one development` and `one production` separately

## Web

- Generate key pair
- OR Import existing key pair

## Install Firebase CLI

By following this [guide](https://firebase.google.com/docs/cli#sign-in-test-cli)

```s
$ curl -sL https://firebase.tools | bash
$ firebase login
$ dart pub global activate flutterfire_cli
$ flutterfire configure --project={input project name at here}
```

## Install FCM plugin

```s
$ flutter pub add firebase_messaging
```

## Access Registration Token

Guide: <https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=en#access_the_registration_token>

```dart
// for general
final fcmToken = await FirebaseMessaging.instance.getToken();

// for web platform
final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BKagOny0KF_2pCJQ3m....moL0ewzQ8rZu");

// notify token refresh
FirebaseMessaging.instance.onTokenRefresh
    .listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    })
    .onError((err) {
      // Error getting token.
    });
```

## Prevent auto initialization

Guide: <https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=en#prevent-auto-init>

# Send Test Message

At this step, should be able to send from notification composer now. Here are the steps:

> Install and run the app on the target device. On Apple devices, you'll need to accept the request for permission to receive remote notifications.
> Make sure the app is in the background on the device.
> Open the Notifications composer and select New notification.
> Enter the message text.
> Select Send test message.
> In the field labeled Add an FCM registration token, enter the registration token you obtained in a previous section of this guide.
> Click Test

# Receive Message

## Request permission (Apple and Web)

```dart
FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

print('User granted permission: ${settings.authorizationStatus}');
```

## Handling Message

Guide: <https://firebase.google.com/docs/cloud-messaging/flutter/receive?hl=en#message_handling>

Payload message type: <https://firebase.google.com/docs/cloud-messaging/concept-options#notifications_and_data_messages>

### Foreground Message

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
});
```

### Background Message

- Apple and Android
  - It must not be an anonymous function.
  - It must be a top-level function (e.g. not a class method which requires initialization).
```dart
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
```

- Web
  - create a new file in the your web directory, and call it `firebase-messaging-sw.js`:

```js
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "...",
  authDomain: "...",
  databaseURL: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
```

  - after the main.dart.js file has loaded, register your worker:

```js
<html>
<body>
  ...
  <script src="main.dart.js" type="application/javascript"></script>
  <script>
       if ('serviceWorker' in navigator) {
          // Service workers are supported. Use them.
          window.addEventListener('load', function () {
            // ADD THIS LINE
            navigator.serviceWorker.register('/firebase-messaging-sw.js');

            // Wait for registration to finish before dropping the <script> tag.
            // Otherwise, the browser will load the script multiple times,
            // potentially different versions.
            var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;

            //  ...
          });
      }
  </script>
```

# Troubleshooting

## 1. Apple Push Service Certificate is not trusted

Here is online [solution](https://stackoverflow.com/questions/71211405/apple-push-service-certificate-is-not-trusted)

- Go to KeyChain -> select that certificate -> Get Info
- Find `Common Name` and `Organizational Unit`
- Go to <https://www.apple.com/certificateauthority/> to download corresponding certificate
- Check not trusted certificate again

#### Reference

- Practice Project: <https://github.com/HevaWu/TestFlutterFCM>
- <https://firebase.flutter.dev/docs/messaging/overview/>
- <https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=en>
- <https://firebase.google.com/docs/flutter/setup?platform=ios>
- <https://firebase.google.com/docs/cli#sign-in-test-cli>
