---
layout: post
title: User Privacy and Data Use
date: 2020-08-13 15:12:00
comment_id: 93
categories: [WWDC2020]
tags: [Privacy]
---

# 4 Fondamental Privacy Pillars

- On-device processing
- Data minimization
- Security protections
- Transparency and control

## On-device processing

The benefit of operating on data without sending it off of a user's device to a remote server is: when you send data to a remote server, user loses their ability to control who can access it, who the data will turn be shared with and what the data may be used for. It requres extra work to secure customer data. But sometimes we just need data to train a ML model. So, it should be okay to leverage CoreML to build and train models on-device. And keeping data locally takes advantage of the strong security protections we have on our devices.

Since iOS 13, Apple support PFL(Private Federated Learning) to build ML models on potentially sensitive data. PFL works by having devices send idfferentially private model updates. By this way, we could build centralized models on our servers without ever having access to user data.

Some example: 

- QuickType Keyboard
- QuickType Quick Reply
- Hey Siri Vocal Classifier
- Photo Sharing
- Dictation Language Models (on-device dictation)
- HomeKit Secure Video Object Detection (on-device intelligence)

## Data minimization

Asking for what you need.

- Photo
- Location
- Contacts

### Photo

- Limited Photo Library: User can give apps access to only a limited selection of their photos instead of their entire photos library.

![limited](/images/2020-08-13-User-Privacy-and-Data-Use/limited.png)

- PHPicker: replacement for UIImagePickerController, impoved with search and multi-select, doesn't require user to grant Phots Library access

![PHPicker](/images/2020-08-13-User-Privacy-and-Data-Use/PHPicker.png)

### Location

- Approximate location by default

![approximate_location](/images/2020-08-13-User-Privacy-and-Data-Use/approximate_location.png)

### Contacts

- TextField textContentType: quick filtering the contacts info

![textContentType](/images/2020-08-13-User-Privacy-and-Data-Use/textContentType.png)

## Security protections

### DNS

Since DNS queries do not support either confidentiality or authenticity, the queryies and server addressess can be read or even modified by third parties. We need encryped connection.

Start from 2020, Apple natively support 2 standard encrypted DNS protocols.

![DNS_protocol](/images/2020-08-13-User-Privacy-and-Data-Use/DNS_protocol.png)

## TLS

TLS session establishment includes a plaintext Server Name Indication, or SNI. The SNI can be observed by a third party on the network, telling them the name of the server you are making a connection with.

## Transparency and control

When submit App to AppStore, required to answer:

- What data do you collect?
- How is the data used?
- Is the data linked to a particular user or device?
- Do you use this data to track users?

![data_used](/images/2020-08-13-User-Privacy-and-Data-Use/data_used.png)

**Note:**
**SDKs are part of the app too. It is required to declare what the data they collect and how it is used.**

### ITP(Intelligent Tracking Prevention)

Since iOS 11 and Safari 11, ITP used to protect user access from toolbar. 

### Clipbard

In iOS 14, Apple making it clear to developers and users when apps access pasteboard items from another app.

### Camera or Mic

When an app turns on the camera or mic, the indicator will appear in the status bar to show apps are recording.

### Network privacy - Local network

When app try to access the local network will trigger a prompt to the user requesting permission.

![local_network](/images/2020-08-13-User-Privacy-and-Data-Use/local_network.png)

### Network privacy - Wi-Fi address

Introduce private Wi-Fi address. iOS 14 will automatically manage Wi-Fi Mac addresses when joininig networks.

- Per-network address
- Not linked to identity
- Generated daily
- Users alwasy in control

![private_network](/images/2020-08-13-User-Privacy-and-Data-Use/private_network.png)

### Nearby Interaction framework

![nearby_interaction](/images/2020-08-13-User-Privacy-and-Data-Use/nearby_interaction.png)

### App Clips

Location access part. Location confirmation reveals just enough information to accomplish this without the need for full location access.

![app_clips](/images/2020-08-13-User-Privacy-and-Data-Use/app_clips.png)

### Safari web extensions

Configure extension to request the minimum permissions necessary.

# Conclusion

App Store policy will require apps to ask before tracking users across apps and Web sites owned by other companies. Your app must display this prompt and only track users across apps and websites owned by other companies if they tap Allow Tracking.

![tracking_transparency](/images/2020-08-13-User-Privacy-and-Data-Use/tracking_transparency.png)

This includes:

- Targeted advertising
- Advertising measurement
- Sharing with data brokers

If it counts tied to User ID, Identifier for Advertising(IDFA), Device ID, Fingerprinted ID, Profile.

User permission not requried for:

- Linking done solely on user's device. (Data cannot be sent off the device in a way that can identify that user or device)
- Sharing with a data broker solely for fraud detection, prevention, or security

Use the `AppTrackingTransparency` framework to request permission to track. It requires `NSUserTrackingUsageDescription` in Info.plist. Need to a add clear description of why you're asking to track the user.

![NSUserTrackingUsageDescription](/images/2020-08-13-User-Privacy-and-Data-Use/NSUserTrackingUsageDescription.png)

- Access to IDFA requires asking for permission to track
- AppTrackingTransparency framework available in iOS 14 SDK

IDFA is one of the identifiers that is controlled by the new tracking permission. If user select `Ask App Not to Track`, the IDFA API will return all zeros.

- User can choose to not be asked by any app for tracking permissions. 
- Limit Ad Tracking ON prevents apps from asking
- Switch locked off for Child account, Shared iPad

![allow_tracking](/images/2020-08-13-User-Privacy-and-Data-Use/allow_tracking.png)

User can disallow tracking permission at any time. 

- Call the `AppTrackingTransparency` framework everytime the app is launched before you want to use the IDFA
- Do not cache or store the IDFA
- Think about what changes you should make to stop tracking a user after they switch tracking off

## SKAdNetwork improvements

- Measure conversion without user tracking
- On-device intelligence
- Aggregation
- Does not require tracking permission

![ad](/images/2020-08-13-User-Privacy-and-Data-Use/ad.png)

#### Reference

<https://developer.apple.com/app-store/user-privacy-and-data-use/>

<https://developer.apple.com/videos/play/wwdc2020/10676/>
