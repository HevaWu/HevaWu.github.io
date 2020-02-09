---
layout: post
title: Swift Modulus
date: 2020-02-09 21:25:00
comments: true
disqus_category_id: SwiftModulus
categories: [Swift]
tags: [Operation]
---

In Swfit Operation, `%` compute the remainder of the integer division:

```swift
a % b = a - (a/b) * b
```

where `/` is the truncating integer division.

The question is:

**What should we do for negative integer mod?**

I search lots of matieral, since Swift didn't calculate this result correctly. So if there is a negative number, the `true` modulus would be:

```swift
func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

print(mod(-1, 3)) // 2
```

#### Reference

https://en.wikipedia.org/wiki/Modulo_operation
https://stackoverflow.com/questions/41180292/negative-number-modulo-in-swift