---
layout: post
title: Modern Swift API Design
date: 2019-06-12 15:59:00
comment_id: 15
categories: [iOS, WWDC2019, Swift]
tags: [API Design]
---

# Guidelines
`swift.org/documentation/api-design-guidelines`

# Clarity the point of use

- No Prefixes in Swift-only Frameworks

## Values and References

Classes - Reference Types
Structs and Enums - Value Types

### Choosing - Reference or Value ?

Prefer structs over classes

- Only choose classes when reference semantics are important

Classes can make a good choice when

- You need a reference counting and deinitialization
- The value is held centrally and shared
- Where there is held centrally and shared

### Value and Reference Semantics

Value types makes copy of reference types

## Protocols and Generics

Don't literally start with a protocol

- Start with concrete use cases
- Discover a need for generic code
- Try to compose solutions from existing protocols first
- Consider a generic type instead of a protocol

Protocol for code reuse, otherwise use generics.

### Key Path Member Lookup

Swift Evolution: SE-0252
`@dynamicMemberLookup` & `subscript`
`$` backing storage property, binding property, key path member lookup

## Property Wrapper

`@LateInitialized` <- give a private policy
Provides similar benefits to the built-in `lazy`

- Eliminates boilerplate
- Documents semantics at the point of definition

Property wrappers reuse computed property definitions.

### Using Property Wrappers

Uses of property wrappers expand into a stored property and a computed property

### Using the DefensiveCopying Property Wrapper

`@DefensiveCopying` Variables can be initialized in their declaration

- Property Wrappers in UserDefault
- Property Wrappers in SwiftUI
