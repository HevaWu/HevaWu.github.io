---
layout: post
title: Try Vision Sample Code
date: 2019-07-26 12:33:00
comments: true
disqus_category_id: TryVisionSampleCode
categories: [iOS, Vision]
tags: [Vision]
---

WWDC 2019 Introduce the `Vision` Framework.
And they also provide the Sample Code !!!

How exciting! Let's try it!

## Classifying Images for Categorization and Search

This is sample project for labeling/categorizing the giving images.

### Requirements

```s
SDKs: macOS 10.15+
Xcode: 11.0+
```

![classify_image.gif](/images/2019-07-26-Try-Vision-Sample-Code/classify_image.gif)

## Analyzing Image Similarity with Feature Print

This is sample project for checking how silimarity between several pictures.
Sorry I didn't update my device to iOS 13.
So the only thing I could attach at here is the video-cut from WWDC video.

![image_similarity.gif](/images/2019-07-26-Try-Vision-Sample-Code/image_similarity.gif)

## Highlighting Areas of Interest in an Image Using Saliency

This is sample project for bounding people forcused area.
I only try in on macOS.

After selecting the picture you want to anlyze, `Rects` cut the saliency bound,
and `Mask` give us the saliency masks. `Combind` means combine the bounds & masks,
which will show the saliency area above the picture.

![highlight_image_saliency.gif](/images/2019-07-26-Try-Vision-Sample-Code/highlight_image_saliency.gif)
