---
layout: post
title: Gift Wrapping Algorithm(Jarvis Algorithm)
date: 2021-09-03 22:44:00
comment_id: 192
categories: [Computational Geometry, Convex Hull, Algorithm]
---

> the `gift wrapping algorithm` is an algorithm for computing the [`convex hull`](https://en.wikipedia.org/wiki/Convex_hull) of a given set of points.

![](/images/2021-09-03-Gift-Wrapping-Algorithm-Jarvis-Algorithm/Animation_depicting_the_gift_wrapping_algorithm.gif#simulator)

> The gift wrapping algorithm begins with $i=0$s and a point $p_0$ known to be on the convex hull, e.g., the leftmost point, and selects the point $pi_{i+1}$ such that all points are to the right of the line $p_i p_{i+1}$. This point may be found in $O(n)$ time by comparing polar angles of all points with respect to point $p_i$ taken for the center of polar coordinates. Letting $i=i+1$, and repeating with until one reaches $p_h=p_0$ again yields the convex hull in $h$ steps. In two dimensions, the gift wrapping algorithm is similar to the process of winding a string (or wrapping paper) around the set of points.

## Pseudocode

```sh
algorithm jarvis(S) is
    // S is the set of points
    // P will be the set of points which form the convex hull. Final set size is i.
    pointOnHull = leftmost point in S // which is guaranteed to be part of the CH(S)
    i := 0
    repeat
        P[i] := pointOnHull
        endpoint := S[0]      // initial endpoint for a candidate edge on the hull
        for j from 0 to |S| do
            // endpoint == pointOnHull is a rare case and can happen only when j == 1 and a better endpoint has not yet been set for the loop
            if (endpoint == pointOnHull) or (S[j] is on left of line from P[i] to endpoint) then
                endpoint := S[j]   // found greater left turn, update endpoint
        i := i + 1
        pointOnHull = endpoint
    until endpoint = P[0]      // wrapped around to first hull point
```

## Time Complexity

$O(nh)$, where $n$ is the number of points and $h$ is the number of points on the convex hull.

The run time depends on the size of the output, so Jarvis's march is an [output-sensitive algorithm](https://en.wikipedia.org/wiki/Output-sensitive_algorithm).

#### References

- <https://en.wikipedia.org/wiki/Gift_wrapping_algorithm>
