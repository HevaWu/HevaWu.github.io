---
layout: post
title: Objective C - copy, assign, retain
date: 2023-02-24 23:15:00
comment_id: 233
categories: [iOS, Objective-C]
tags: [MRC]
---

## copy

Specifies that a copy of the object should be used for assignment.

The previous value is sent a release message.

The copy is made by invoking the copy method. This attribute is valid only for object types, which must implement the NSCopying protocol.

### Memo

- Difference between `copy` and `retain` is, `retain` will reference pointer address, where `copy` is copy the element itself. When property is be `retain`, and change some property, the related will be changed together. For `copy`, it will not effect others.

## assign

Specifies that the setter uses simple assignment. This attribute is the default.

You use this attribute for scalar types such as NSInteger and CGRect.

### Memo

- `assign` will not increasing the reference, when the property de-allocated, it will be released. Even other variable call it, they cannot keep it, it will only cause crash. Even it is released, the pointer still exist, because wild pointer, when new variable assign to this address, it will crash.
- So only use this attribute for scalar types, because they will be assign to stack, and be processed by system, which will not cause wild pointer.

## retain

Specifies that retain should be invoked on the object upon assignment.

The previous value is sent a release message.

In OS X v10.6 and later, you can use the **attribute** keyword to specify that a Core Foundation property should be treated like an Objective-C object for memory management:

```objective-c
@property(retain) __attribute__((NSObject)) CFDictionaryRef myDictionary;
```

### Memo

- `retain` will count the reference. When be referenced, count +1, when be released ,count -1. Even though this variable been released, if there is other variable call it, it will be kept. Only when count be 0, it will be dealloc.

#### References

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocProperties.html>
