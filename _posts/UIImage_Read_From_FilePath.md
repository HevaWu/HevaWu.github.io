---
layout: post
title: UIImage Read From FilePath
date: 2020-12-10 20:09:00
comment_id: 117
categories: [iOS]
tags: [UIImage]
---

By retrieving an image from a file, we might try to use `UIImage(named:)` OR `UIImage(contentsOfFile:)`. However, if we store a local image file, these 2 functions might not find the image file successfully.

Someone give the explanation for this issue:

> Don't use UIImage(contentsOfFile:) either, because it's a path-based API. There's no URL-based equivalent, which is an Apple clue that should be doing something else. 
>
> "URL(string:)" creates a generalized URL, not a file URL. Since your path string is just a path, the URL has no explicit scheme, and when it's used it's probably going to default to "http", which isn't what you want.

So, instead of using these 2 functions, we should use `Data` to load the image from file:

```swift
guard let imageData = try? Data(contentsOf: image_file_url, , options: [.mappedIfSafe, .uncached]),
	let image = UIImage(data: imageData) else {
		fatalError("Failed to retrieve image from file path.")
	}
```

#### Reference

- <https://developer.apple.com/forums/thread/78339>
- <https://developer.apple.com/documentation/uikit/uiimage/1624112-init>
