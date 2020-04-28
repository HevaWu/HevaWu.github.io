---
layout: post
title: Swift Fallthrough
date: 2020-04-28 17:39:00
comments: true
disqus_category_id: UploadApptoAppStoreConnect
categories: [Swift]
tags: [Switch]
---

## Switch

`switch` consider a valud and compares it against possible matching patterns.

```swift
switch some value to consider {
case value 1:
    respond to value 1
case value 2,
     value 3:
    respond to value 2 or 3
default:
    otherwise, do something else
}
```

It's just like `if` statement, each case is a separate branch of code execution. Every `switch` statement must be `exhaustive`, which means every possible value of the type being onsidered must be matched by one of the switch cases. If there is no approriate patters, it should be passed to `default` part.

### No implicit fallthrough

`switch` in Swift do not fall through the bottom of each case and into the next one by default. This is for make switch statement safer and easier to use and avoids executing more than one switch case by mistake.

## Fallthrough

For explicitly fall through at the end of particular switch case, we could use `fallthrough` keyword.

```swift
let integerToDescribe = 5
var description = "The number \(integerToDescribe) is"
switch integerToDescribe {
case 2, 3, 5, 7, 11, 13, 17, 19:
    description += " a prime number, and also"
    fallthrough
default:
    description += " an integer."
}
print(description)
// Prints "The number 5 is a prime number, and also an integer."
```

`fallthrough` does not check the case conditions for the switch case it causes execution to fall into. It just simply move the execution directly to the statements inside the next case(or even `default` block).

At SwiftLint, it has a `no_fallthrough_only` rule which forbit the single fallthrough line.

```s
No Fallthrough Only Violation: Fallthroughs can only be used if the `case` contains at least one other statement. (no_fallthrough_only)
```

For example:
```swift
// bad
let anotherCharacter: Character = "a"
switch anotherCharacter {
case "a": fallthrough // will show swiftLint warnings at here
case "A":
    print("The letter A")
default:
    print("Not the letter A")
}

// good
let anotherCharacter: Character = "a"
switch anotherCharacter {
case "a", "A":
    print("The letter A")
default:
    print("Not the letter A")
}
// Prints "The letter A"
```

#### Reference

<https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html#ID14>

<https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html>