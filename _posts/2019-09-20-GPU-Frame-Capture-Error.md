---
layout: post
title: GPU Frame Capture Error
date: 2019-09-20 12:15:00
comments: true
disqus_category_id: GPUFrameCaptureError
categories: [Xcode, Error]
tags: [GPU Frame Capture Error]
---

Here is one problem I met when build the project.

```s
GPU Frame Capture
Shader performance data maybe unavailable due to deployment target older than device version.
```

So, after searching, this is only an alert from Xcode which just alert that it `might` be problems on performance data. And it should be okay just ignore it.

If you find it is annoying, you could also close it by
-> Product -> Scheme -> Edit Scheme

![editScheme](/images/2019-09-20-GPU-Frame-Capture-Error/editScheme.jpg)

#### Reference

<https://stackoverflow.com/questions/52509223/shader-performance-data-maybe-unavailable-due-to-deployment-target-older-than-de>