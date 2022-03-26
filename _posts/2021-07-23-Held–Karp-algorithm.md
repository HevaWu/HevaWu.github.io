---
layout: post
title: Held–Karp algorithm
date: 2021-07-23 22:00:00
comment_id: 176
categories: [Algorithm]
tags: [DP]
---

> The Held–Karp algorithm, also called Bellman–Held–Karp algorithm, is a dynamic programming algorithm to solve [the traveling salesman problem (TSP)](https://en.wikipedia.org/wiki/Traveling_salesman_problem).
>
> The input is a distance matrix between a set of cities, and the goal is to find a minimum-length tour that visits each city exactly once before returning to the starting point. It finds the exact solution to this problem, and to several related problems including the Hamiltonian circuit problem, in exponential time.

Suppose ${\displaystyle S=\{s_{1},\ldots ,s_{k}\}}$ is a set of ${\displaystyle k}$ cities. For every integer ${\displaystyle 1\leq i\leq k}$, write ${\displaystyle S_{i}=S\setminus \{s_{i}\}=\{s_{1},\ldots ,s_{i-1},s_{i+1},\ldots ,s_{k}\}}$ for the set created by removing $s_{i}$ from $S$. Then if the shortest path from $1$ through $S$ to $e$ has $s_{i}$ as its second-to-last city, then removing the final edge from this path must give the shortest path from $1$ to $s_{i}$ through $S_{i}$. This means there are only $k$ possible shortest paths from $1$ to $e$ through $S$, one for each possible second-to-last city $s_{i}$ with length ${\displaystyle g(S_{i},s_{i})+d(s_{i},e)}$, and ${\displaystyle g(S,e)=\min _{1\leq i\leq k}g(S_{i},s_{i})+d(s_{i},e)}$.

This stage of the algorithm finishes when ${\displaystyle g(\{2,\ldots ,i-1,i+1,\ldots ,n\},i)}$ is known for every integer ${\displaystyle 2\leq i\leq n}$, giving the shortest distance from city $1$ to city $i$ that passes through every other city. The much shorter second stage adds these distances to the edge lengths ${\displaystyle d(i,1)}$ to give $n-1$ possible shortest cycles, and then finds the shortest.

The shortest path itself (and not just its length), finally, may be reconstructed by storing alongside ${\displaystyle g(S,e)}$ the label of the second-to-last city on the path from $1$ to $e$ through $S$, raising space requirements by only a constant factor.

## Time Complexity

${\displaystyle \Theta (2^{n}n^{2})}$

Computing one value of ${\displaystyle g(S,e)}$ for a $k$-element subset $S$ of ${\displaystyle \{2,\ldots ,n\}}$ requires finding the shortest of $k$ possible paths, each found by adding a known value of $g$ and an edge length from the original graph; that is, it requires time proportional to $k$. There are ${\textstyle {\binom {n-1}{k}}}$ $k$-element subsets of ${\displaystyle \{2,\ldots ,n\}}$; and each subset gives $n-k-1$ possible values of $e$. Computing all values of ${\displaystyle g(S,e)}$ where ${\displaystyle S=k}$, thus requires time ${\textstyle k(n-k-1){\binom {n-1}{k}}=(n-1)(n-2){\binom {n-3}{k-1}}}$, for a total time across all subset sizes ${\textstyle (n-1)(n-2)\sum _{k=1}^{n-2}{\binom {n-3}{k-1}}=(n-1)(n-2)2^{n-3}=\Theta (n^{2}2^{n})}$. The second stage of the algorithm, finding a complete cycle from $n-1$ candidates, takes $\Theta (n)$ time and does not affect asymptotic performance.

## Space Complexity

${\displaystyle \Theta (n2^{n})}$

Storing all values of ${\displaystyle g(S,e)}$ for subsets of size $k$ requires keeping ${\textstyle (n-k-1){\binom {n-1}{k}}=(n-1){\binom {n-2}{k}}}$ values. A complete table of values of ${\displaystyle g(S,e)}$ thus requires space ${\textstyle \sum _{k=0}^{n-2}(n-1){\binom {n-2}{k}}=(n-1)2^{n}=\Theta (n2^{n})}$.

If only the length of the shortest cycle is needed, not the cycle itself, then space complexity can be improved somewhat by noting that calculating ${\displaystyle g(S,e)}$ for a $S$ of size $k$ requires only values of $g$ for subsets of size $k-1$. Keeping only the ${\textstyle (n-1)\left[{\binom {n-2}{k-1}}+{\binom {n-2}{k}}\right]}$ values of ${\displaystyle g(S,e)}$where $S$ has size either $k-1$ or $k$ reduces the algorithm's maximum space requirements, attained when ${\textstyle k=\left\lfloor {\frac {n}{2}}\right\rfloor }$, to ${\displaystyle \Theta ({\sqrt {n}}2^{n})}$.

## Pseudocode

```s
function algorithm TSP (G, n) is
    for k := 2 to n do
        C({k}, k) := d1,k
    end for

    for s := 2 to n−1 do
        for all S ⊆ {2, . . . , n}, |S| = s do
            for all k ∈ S do
                C(S, k) := minm≠k,m∈S [C(S\{k}, m) + dm,k]
            end for
        end for
    end for

    opt := mink≠1 [C({2, 3, . . . , n}, k) + dk, 1]
    return (opt)
end function
```

#### Reference

- <https://en.wikipedia.org/wiki/Held%E2%80%93Karp_algorithm>
