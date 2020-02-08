---
layout: post
title: Swift In-Out
date: 2020-02-08 16:58:00
comments: true
disqus_category_id: SwiftInOut
categories: [Swift]
tags: [Declarations]
---

Swift Function parameters are constant by default. <- we can't change the value of a parameter. If we want function to modify a parameter's value, and want those changes to persist after function has ended, define the parameters as `inout` parameter instead.

> - When the function is called, the value of the argument is copied.
>
> - In the body of the function, the copy is modified.
>
> - When the function returns, the copy’s value is assigned to the original argument.

The behavior is known as `copy-in copy-out` or `call by value result`.

As an optimization, when the argument is a value stored at a physical address in memory, the same memory location is used both inside and outside the function body(`call by reference`), it satisfies all of the requirements of the copy-in copy-out model while removing the overhead of copying.

## Memory Safety

Within a function, don't access a value that was passed as an in-out argument, even if the original value is available in the current scope. Acessing the original is a simultaneus access of the value, which violates Swift's memory exclusivity guarantee.

## Note

A closure or nested function that captures an in-out parameter must be nonescaping. If you need to capture an in-out parameter without mutating it or to observe changes made by other code, use a capture list to explicitly capture the parameter immutably.

```swift
func someFunction(a: inout Int) -> () -> Int {
    return { [a] in return a + 1 }
}
```

If you need to capture and mutate an in-out parameter, use an explicit local copy, such as in multithreaded code that ensures all mutation has finished before the function returns.

```swift
func multithreadedFunction(queue: DispatchQueue, x: inout Int) {
    // Make a local copy and manually copy it back.
    var localX = x
    defer { x = localX }

    // Operate on localX asynchronously, then wait before returning.
    queue.async { someMutatingOperation(&localX) }
    queue.sync {}
}
```

## More Uses

Place an ampersand `&` to indicate it can be modified by the function.

**Note**

> In-out parameters cannot have default values, and variadic parameters cannot be marked as inout.

```swift
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var someInt = 3
var anotherInt = 107
swapTwoInts(&someInt, &anotherInt)
print("someInt is now \(someInt), and anotherInt is now \(anotherInt)")
// Prints "someInt is now 107, and anotherInt is now 3"
```

**Note**

> In-out parameters are not the same as returning a value from a function. The swapTwoInts example above does not define a return type or return a value, but it still modifies the values of someInt and anotherInt. In-out parameters are an alternative way for a function to have an effect outside of the scope of its function body.

#### References

https://docs.swift.org/swift-book/LanguageGuide/Functions.html
https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID545