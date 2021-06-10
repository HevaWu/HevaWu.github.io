---
layout: post
title: WWDC2021 Explore WKWebView Additions
date: 2021-06-10 15:29:00
comment_id: 165
categories: [WWDC2021, Swift]
tag: [WKWebView]
---

# SFSafariViewController

![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/safari.png)

# WKWebView

## JS API

- access theme color
  - underPageBackgroundColor
  - themeColor
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/theme.png)

- manage text interaction
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/text.png)

- control media playback
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/media.png)

## Browser API

- Disable HTTPS upgrade
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/https.png)

- Control media capture
  - `getUserMedia`
  - origin request can be the app
  - decide when to re-prompt user
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/prompt.png)
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/bypass.png)
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/camera.png)

- Manage downloads
  - Use `WKDownload` and `WKDownloadDelegate`
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/download.png)
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/serverDownload.png)
![](/images/2021-06-10-WWDC2021-Explore-WKWebView-Additions/appDownload.png)

#### Reference

- <https://developer.apple.com/wwdc21/10032>
