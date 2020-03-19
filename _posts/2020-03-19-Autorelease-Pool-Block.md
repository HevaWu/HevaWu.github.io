---
layout: post
title: Autorelease Pool Block
date: 2020-03-19 19:47:00
comments: true
disqus_category_id: AutoreleasePoolBlock
categories: [Apple]
tags: [Dealloc]
---

> Autorelease pool blocks provide a mechanism whereby you can relinquish ownership of an object, but avoid the possiblity of it being deallocated immediately.

It could be used as:

```objective-c
@autoreleasepool {
    // Code that creates autoreleased objects.
}
```

Cocoa always expects code to be executed within an autorelease pool bbblock, otherwise autoreleased objects do not get released and the application might cause memory leak. AppKit and UIKit frameworks process each event-loop iteration within an autorelease pool block. Therefore you typicallu do not have to create an autorelease pool block yourself, but three occasions when you might use your won autorelease pool blocks:

- If you are writing a program that is not based on a UI framework, such as a command-line tool.
- If you write a loop that creates many temporary objects.
You may use an autorelease pool block inside the loop to dispose of those objects before the next iteration. Using an autorelease pool block in the loop helps to reduce the maximum memory footprint of the application.
- If you spawn a secondary thread. You must create your own autorelease pool block as soon as the thread begins executing; otherwise, your application will leak objects. (See Autorelease Pool Blocks and Threads for details.)

> Each thread in a Cocoa application maintains its own stack of autorelease pool blocks. If you are writing a Foundation-only program or if you detach a thread, you need to create your own autorelease pool block.
> 
> If your application or thread is long-lived and potentially generates a lot of autoreleased objects, you should use autorelease pool blocks (like AppKit and UIKit do on the main thread); otherwise, autoreleased objects accumulate and your memory footprint grows. If your detached thread does not make Cocoa calls, you do not need to use an autorelease pool block.

#### Reference

https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmAutoreleasePools.html