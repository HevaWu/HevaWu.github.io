---
layout: post
title: Upload app to App Store Connect
date: 2020-04-10 16:27:00
comment_id: 79
categories: [App Store, Xcode]
tags: [Xcode11]
---

## Questions

Before Xcode 11, we could upload app binary via `Application Loader`. But Xcode 11 removed it.

<https://developer.apple.com/documentation/xcode_release_notes/xcode_11_release_notes>

> Xcode supports uploading apps from the Organizer window or from the command line with xcodebuild or xcrun altool. Application Loader is no longer included with Xcode. (29008875)

## Solutions

Then how should we upload app for now?

Here, just imagine we've already got the `ipa` file. For more detials abou the archive, [this guideline](https://help.apple.com/xcode/mac/current/#/dev442d7f2ca) would be helpful.

According to [Apple Doc](https://help.apple.com/app-store-connect/#/devb1c185036), we could have 2 ways to upload `ipa` to App Store.

### altool

> You can use xcrun (included with Xcode) to invoke altool, a command-line tool that lets you notarize, validate, and upload your app binary files to the App Store.

```shell
$ xcrun altool --validate-app -f file -t platform -u username [-p password] [--output-format xml]
$ xcrun altool --upload-app -f file -t platform -u username [-p password] [—output-format xml]
```

For `atool`, [here](https://help.apple.com/asc/appsaltool/) is the doc.

### Transporter app

> The Transporter app for macOS is a simple and easy way to upload an app to App Store Connect for distribution on the App Store. In addition to uploading your build, you can view delivery progress (including warnings, errors, and delivery logs), as well as a history of past deliveries.

We could just download the `Transporter` app from Mac App Store and use it.

#### Reference

<https://help.apple.com/app-store-connect/#/devb1c185036>