---
layout: post
title: Fatal error could not demangle keypath type
date: 2021-01-22 22:06:00
comment_id: 134
categories: [Swift]
tags: [Compiler]
---

When I tried to implement some KVO pattern in my personal project, I got some interesting error: `Fatal Error: Could not demangle keypath type from xxx`.

The test code is:

```swift
class A {
    static let valueDidChange = Notification.Name("valueDidChange")
        
    var val: String {
        willSet {
            NotificationCenter.default.post(name: Self.valueDidChange, object: self, userInfo: [\Self.val: newValue])
        }
    }
    
    init(val: String) {
        self.val = val
    }
}

class B {
    var observer: NSObjectProtocol?
    
    var a: A
    @objc dynamic var val: String
    
    init(a: A) {
        self.a = a
        self.observer = NotificationCenter.default.addObserver(forName: A.valueDidChange, object: nil, queue: nil, using: { [weak self] notice in
            self?.val = notice.userInfo?[\A.val] as? String ?? ""
        })
    }
}
```

For fixing this issue, if I change `A.val willSet` part as ⬇️, it will pass.

```swift
var val: String {
	willSet {
		NotificationCenter.default.post(name: A.valueDidChange, object: self, userInfo: [\A.val: newValue])
	}
}
```

It seems this is a compiler bug, which is not solved until I write this blog. -> <https://bugs.swift.org/browse/SR-12428>
Swift compiler was not properly handling key paths containing covariant `Self` type. So it'd be safer to use className rather than covariant `Self` type at here.

I'd like to [paste someone's answer](https://stackoverflow.com/a/62966092) at here:

> the Swift compiler did not include any logic to handle dynamic Self when creating a key path. Under-the-hood, it essentially tried to emit a key path object of type ReferenceWritableKeyPath<Self, CGFloat>. The type system doesn't allow you to use dynamic Self in that context, and the runtime was not expecting it. The strange error message you received was the result of trying to decode this unexpected object type, which was encoded as a 4-byte relative pointer to the metadata for your V class, followed by the suffix XD indicating a dynamic Self type (hence the error message containing 4 �'s followed by XD). By playing around with different ways to create key paths involving dynamic Self, I came across a number of different crashes at both compile-time and runtime.

#### Reference

- <https://stackoverflow.com/questions/61137449/fatal-error-could-not-demangle-keypath-type>
- <https://bugs.swift.org/browse/SR-12428>
