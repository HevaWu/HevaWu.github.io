---
layout: post
title: Cycle detection
date: 2021-01-22 22:25:00
comment_id: 135
categories: [Algorithm]
tags: [Search]
---

> Cycle detection or cycle finding is the algorithmic problem of `finding a cycle in a sequence of iterated function values`.

For any function f that maps a finite set S to itself, and any initial value x0 in S, the sequence of iterated function values

$$
{\displaystyle x_{0},\ x_{1}=f(x_{0}),\ x_{2}=f(x_{1}),\ \dots ,\ x_{i}=f(x_{i-1}),\ \dots }
$$

must eventually use the same value twice: there must be some pair of distinct indices $i$ and $j$ such that $x_i = x_j$. Once this happens, the sequence must continue periodically, by repeating the same sequence of values from $x_i$ to $x_{j − 1}$. Cycle detection is the problem of finding $i$ and $j$, given $f $and $x_0$.

## Floyd's cycle-finding algorithm

> Floyd's cycle-finding algorithm is a pointer algorithm that uses only two pointers, which move through the sequence at different speeds.

Idea:

- If there is a cycle, for any integers $i ≥ μ$ and $k ≥ 0$, $x_i = x_i + kλ$, where $λ$ is the length of the loop to be found and $μ$ is the index of the first element of the cycle. 
- $i = kλ ≥ μ$ for some $k$ if and only if $x_i = x_{2i}$.
- one twice as far from the start of the sequence as the other, to find a period ν of a repetition that is a multiple of $λ$. Once $ν$ is found, the algorithm retraces the sequence from its start to find the first repeated value $x_μ$ in the sequence, using the fact that $λ$ divides $ν$ and therefore that $x_μ = x_{μ + v}$. 
- once the value of $μ$ is known it is trivial to find the length $λ$ of the shortest repeating cycle, by searching for the first position $μ + λ$ for which $x_{μ + λ} = x_μ$.

### Python

```python
def floyd(f, x0):
    # Main phase of algorithm: finding a repetition x_i = x_2i.
    # The hare moves twice as quickly as the tortoise and
    # the distance between them increases by 1 at each step.
    # Eventually they will both be inside the cycle and then,
    # at some point, the distance between them will be
    # divisible by the period λ.
    tortoise = f(x0) # f(x0) is the element/node next to x0.
    hare = f(f(x0))
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(f(hare))
  
    # At this point the tortoise position, ν, which is also equal
    # to the distance between hare and tortoise, is divisible by
    # the period λ. So hare moving in circle one step at a time, 
    # and tortoise (reset to x0) moving towards the circle, will 
    # intersect at the beginning of the circle. Because the 
    # distance between them is constant at 2ν, a multiple of λ,
    # they will agree as soon as the tortoise reaches index μ.

    # Find the position μ of first repetition.    
    mu = 0
    tortoise = x0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)   # Hare and tortoise move at same speed
        mu += 1
 
    # Find the length of the shortest cycle starting from x_μ
    # The hare moves one step at a time while tortoise is still.
    # lam is incremented until λ is found.
    lam = 1
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        lam += 1
 
    return lam, mu
```

#### Reference

- <https://en.wikipedia.org/wiki/Cycle_detection>
