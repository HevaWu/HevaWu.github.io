---
layout: post
title: Swift Int Bit Transfer
date: 2020-12-15 23:03:00
comment_id: 118
categories: [Swift]
tags: [bit]
---

For getting specific bit of an integer in Swift, we could do it by using [bit shifting operator](https://hevawu.github.io/blog/2020/10/27/Swift-Integer-Operators):

```swift
// ex: UInt8 integer 11001
let num = UInt8(25)
for i in stride(from: 7, through: 0, by: -1) {
    let curBit = (num >> i) & 1
    print(curBit)
}
/* Output:
0
0
0
1
1
0
0
1
which is 00011001
*/
```

Swift also provide a [String init(_:radix:uppercase:)](https://developer.apple.com/documentation/swift/string/2997127-init) function for directly transfer Int to given base String format:

```swift
let v = 999_999
print(String(v, radix: 2))
// Prints "11110100001000111111"

print(String(v, radix: 16))
// Prints "f423f"
print(String(v, radix: 16, uppercase: true))
// Prints "F423F"
```

which could be convert to Int by [Int init(_:radix:)](https://developer.apple.com/documentation/swift/int/2924481-init):

```swift
let x = Int("123")
// x == 123

let y = Int("-123", radix: 8)
// y == -83
let y = Int("+123", radix: 8)
// y == +83

let z = Int("07b", radix: 16)
// z == 123
```

#### Reference

- <https://developer.apple.com/documentation/swift/int/2924481-init>
- <https://developer.apple.com/documentation/swift/string/2997127-init>
