---
layout: post
title: Digital Root
date: 2022-02-08 15:50:00
comment_id: 204
categories: [Math]
---

> The `digital root (also repeated digital sum)` of a natural number in a given radix is the (single digit) value obtained by an iterative process of summing digits, on each iteration using the result from the previous iteration to compute a digit sum. The process continues until a single-digit number is reached.

For example, in base 10, the digital root of the number 12345 is 6 because the sum of the digits in the number is 1 + 2 + 3 + 4 + 5 = 15, then the addition process is repeated again for the resulting number 15, so that the sum of 1 + 5 equals 6, which is the digital root of that number.

> In base 10, this is equivalent to taking the remainder upon division by 9 (except when the digital root is 9, where the remainder upon division by 9 will be 0).

## Formula

$$
dr_b(n) =
\begin{cases}
0 &\text{if } n = 0 \\
b-1 &\text{if } n \neq 0, n \equiv 0 \ \bmod \  b-1 \\
n \ \bmod (b-1) &\text{if } n \not \equiv 0 \bmod b-1
\end{cases}
$$

OR

$$
dr_b(n) =
\begin{cases}
0 &\text{if } n = 0 \\
1 + ((n-1) \bmod (b-1)) &\text{if } n \neq 0
\end{cases}
$$

### Code

```swift
func addDigits(_ num: Int) -> Int {
    if num == 0 { return 0}
    if num % 9 == 0 { return 9 }
    return num % 9
}
```

```java
public int addDigits(int num) {
    return 1 + (num-1)%9;
}
```

```py
def addDigits(self, num: int) -> int:
    if num == 0:
        return 0
    elif num % 9 == 0:
        return 9
    else:
        return num % 9
```

#### References

- <https://en.wikipedia.org/wiki/Digital_root>
