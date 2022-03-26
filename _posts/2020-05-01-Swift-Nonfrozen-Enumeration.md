---
layout: post
title: Swift Nonfrozen Enumeration
date: 2020-05-01 19:48:00
comment_id: 82
categories: [Swift]
tags: [Enum]
---

Start from Swift 5, you might got some warnings such as `Switch covers known cases, but ** may have additional unknown values, possibly added in future versions`. This warnings will show when you are switching a `non-frozen` enums cases.

## Frozen & Non-Frozen enums

- Frozen enums will never get new cases: Future versions of the library can't change the declaration by adding, removing, or reordering an enumeration's cases or a structure's stored instance properties.
- Non-frozen enums might get new cases in future version: `nonfrozen enumeration` may gain new enumeration cases. When mark an enumeration as nonfrozen, we could add the new enumeration cases later. So enumeration case must be able to handle those future cases.

> When the compiler isn’t in library evolution mode, all structures and enumerations are implicitly frozen, and this attribute is ignored.
>
> Frozen types, the types of the stored properties of frozen structures, and the associated values of frozen enumeration cases must be public or marked with the usableFromInline attribute.

One more difference between frozen & non-frozen enums is:

- fromzen enumeration doesn't require a default case
- non-frozen enumeration require `default` or `@unknown default` case when switch over a frozen enumeration produces a warning because code is never executed.

Example:

```swift
// The following example switches over all three existing cases of the standard library’s Mirror.AncestorRepresentation enumeration. If you add additional cases in the future, the compiler generates a warning to indicate that you need to update the switch statement to take the new cases into account.
let representation: Mirror.AncestorRepresentation = .generated
switch representation {
case .customized:
    print("Use the nearest ancestor’s implementation.")
case .generated:
    print("Generate a default mirror for all ancestor classes.")
case .suppressed:
    print("Suppress the representation of all ancestor classes.")
@unknown default:
    print("Use a representation that was unknown when this code was compiled.")
}
// Prints "Generate a default mirror for all ancestor classes."
```

#### Reference

<https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID620>

<https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID602>