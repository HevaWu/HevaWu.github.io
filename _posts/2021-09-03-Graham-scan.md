---
layout: post
title: Graham scan
date: 2021-09-03 23:13:00
comment_id: 193
categories: [Computational Geometry, Convex Hull, Algorithm]
---

`Graham scan` algorithm finds all vertices of the convex hull ordered along its boundary. It uses a stack to detect and remove concavities in the boundary efficiently.

![](/images/2021-09-03-Graham-scan/GrahamScanDemo.gif#simulator)

## Step

1. find the `point with the lowest y-coordinate`. If the lowest y-coordinate exists in more than one point in the set, the point with the `lowest x-coordinate out of the candidates` should be chosen. Call this point P. This step takes $O(n)$, where $n$ is the number of points in question.
2. the set of points must be `sorted` in increasing order of the angle they and the point P make with the x-axis.
   - Sorting in order of angle does not require computing the angle. It is possible to use any function of the angle which is monotonic in the interval ${\displaystyle [0,\pi ]}$ . The cosine is easily computed using the `dot product`, `or the slope of the line` may be used. If numeric precision is at stake, the comparison function used by the sorting algorithm can use the sign of the `cross product` to determine relative angles.
3. proceeds by considering each of the points in the sorted array in sequence. For each point, it is first determined whether traveling from the two points immediately preceding this point constitutes making a `left turn` or a `right turn`. If a right turn, the second-to-last point is not part of the convex hull, and lies 'inside' it.
   - For three points ${\displaystyle P_{1}=(x_{1},y_{1})}$, ${\displaystyle P_{2}=(x_{2},y_{2})}$ and ${\displaystyle P_{3}=(x_{3},y_{3})}$, compute the z-coordinate of the cross product of the two vectors ${\displaystyle {\overrightarrow {P_{1}P_{2}}}}$ and ${\displaystyle {\overrightarrow {P_{1}P_{3}}}}$ which is given by the expression ${\displaystyle (x_{2}-x_{1})(y_{3}-y_{1})-(y_{2}-y_{1})(x_{3}-x_{1})}$.
   - If the result is `0`, the points are `collinear`;
   - if it is `positive`, the three points constitute a "`left turn`" or counter-clockwise orientation, otherwise a "right turn" or clockwise orientation (for counter-clockwise numbered points).
4. eventually return to the point at which it started, at which point the algorithm is completed and the stack now contains the points on the convex hull in counterclockwise order.

## Pseudocode

```sh
let points be the list of points
let stack = empty_stack()

find the lowest y-coordinate and leftmost point, called P0
sort points by polar angle with P0, if several points have the same polar angle then only keep the farthest

for point in points:
    # pop the last point from the stack if we turn clockwise to reach this point
    while count stack > 1 and ccw(next_to_top(stack), top(stack), point) <= 0:
        pop stack
    push point to stack
end
```

## Time complexity

$O(nlogn)$

#### References

- <https://en.wikipedia.org/wiki/Graham_scan>
