---
layout: post
title: Proto3 fixed64 type
date: 2023-03-17 18:40:00
comment_id: 236
categories: [proto3]
---

proto3 has lists of value types: <https://protobuf.dev/programming-guides/proto3/#scalar>

Inside of them, `fixed64` is a special type I'd like to check & test at here.

From its description:

> Always eight bytes. More efficient than uint64 if values are often greater than 256.

Though it mentioned can be applied to `C++ uint64`, it seems also works for `int64`.

As it mentioned:

> fixed32 is compatible with sfixed32, and fixed64 with sfixed64.

Now, here is one question, how will it be look like if we assign `int64` to `fixed64`?
To be more specifically, positive `int64` will mapped to same value in `fixed64`, how about `negative int64` numbers?

==>

> The “ZigZag” encoding instead of two’s complement to encode negative integers. Positive integers n are encoded as `2 * n` (the even numbers), while negative integers -n are encoded as `2 * n + 1` (the odd numbers). The encoding thus “zig-zags” between positive and negative numbers.

| Signed Original | Encoded As |
| :-------------: | :--------: |
|        0        |     0      |
|       -1        |     1      |
|        1        |     2      |
|       -2        |     3      |
|        …        |     …      |
|   0x7fffffff    | 0xfffffffe |
|   -0x80000000   | 0xffffffff |

> Using some bit tricks, it’s cheap to convert n into its ZigZag representation:
>
> ((n + n) ^ -(n < 0)) - (n < 0)

#### References

- <https://protobuf.dev/programming-guides/proto3/>
