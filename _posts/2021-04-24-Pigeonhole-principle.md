---
layout: post
title: Pigeonhole principle
date: 2021-04-24 11:44:00
comment_id: 150
categories: [Math]
tags: [Performance]
---

> The `pigeonhole principle states` that if $n$ items are put into $m$ containers, with $n>m$, then at least one container must contain more than one item.
>
> Although the pigeonhole principle appears as early as 1624 in a book attributed to Jean Leurechon, it is commonly called `Dirichlet's box principle` or `Dirichlet's drawer principle` after an 1834 treatment of the principle by Peter Gustav Lejeune Dirichlet under the name Schubfachprinzip ("drawer principle" or "shelf principle")

The principle has several generalizations and can be stated in various ways. One of them is:

for natural numbers $k$ and $m$, if $n=km+1$ objects are distributed among $m$ sets, then the pigeonhole principle asserts that at least one of the sets will contain at least $k+1$ objects. For arbitrary $n$ and {$m$ this generalizes to ${\displaystyle k+1=\lfloor (n-1)/m\rfloor +1=\lceil n/m\rceil }$, where ${\displaystyle \lfloor \cdots \rfloor }$ and ${\displaystyle \lceil \cdots \rceil }$ denote the floor and ceiling functions, respectively.

## Alternative formulations

1. If n objects are distributed over m places, and if n > m, then some place receives at least two objects.
2. (equivalent formulation of 1) If n objects are distributed over n places in such a way that no place receives more than one object, then each place receives exactly one object.
3. If n objects are distributed over m places, and if n < m, then some place receives no object.
4. (equivalent formulation of 3) If n objects are distributed over n places in such a way that no place receives no object, then each place receives exactly one object.

## Strong Form

If $k$ discrete objects are to be allocated to $x$ containers, then at least one container must hold at least ${\displaystyle \lceil k/n\rceil }$ objects, where ${\displaystyle \lceil x\rceil }$ is the ceiling function, denoting the smallest integer larger than or equal to $x$. Similarly, at least one container must hold no more than ${\displaystyle \lfloor k/n\rfloor }$ objects, where ${\displaystyle \lfloor x\rfloor }$ is the floor function, denoting the largest integer smaller than or equal to $x$.

#### Reference

- <https://en.wikipedia.org/wiki/Pigeonhole_principle>
