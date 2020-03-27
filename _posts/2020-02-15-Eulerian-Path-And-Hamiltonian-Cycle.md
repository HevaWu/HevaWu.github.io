---
layout: post
title: Eulerian Path And Hamiltonian Path
date: 2020-02-15 19:48:00
comments: true
disqus_category_id: EulerianPathAndHamiltonianCycle
categories: [Algorithm]
tags: [Graph, NPComplete]
---

## Eulerian Path

> In graph theory, an `Eulerian trail` (or `Eulerian path`) is a trail in a finite graph that visits every edge exactly once (allowing for revisiting vertices). Similarly, an `Eulerian circuit` or `Eulerian cycle` is an Eulerian trail that starts and ends on the same vertex.

![Eulerian_Path](/images/2020-02-15-Eulerian-Path-And-Hamiltonian-Cycle/Eulerian_Path.png)

We could find whether a given graph has a Eulerian Path or not in polynomial time. In fact, we can find it in `O(V+E)` time.

### Properties

**Eulerian Cycle**

An undirected graph has Eulerian cycle if following two conditions are true.

- All vertices with non-zero degree are connected. We don’t care about vertices with zero degree because they don’t belong to Eulerian Cycle or Path (we only consider all edges).
- All vertices have even degree.

**Eulerian Path**

An undirected graph has Eulerian Path if following two conditions are true.

- All vertices with non-zero degree are connected. We don’t care about vertices with zero degree because they don’t belong to Eulerian Cycle or Path (we only consider all edges).
- If two vertices have odd degree and all other vertices have even degree. Note that only one vertex with odd degree is not possible in an undirected graph (sum of all degrees is always even in an undirected graph)

**Note**: a graph with no edges is considered Eulerian because there are no edges to traverse.

## Hamiltonian Path

> In the mathematical field of graph theory, a `Hamiltonian path `(or `traceable path`) is a path in an undirected or directed graph that visits each vertex exactly once. A `Hamiltonian cycle` (or `Hamiltonian circuit`) is a Hamiltonian path that is a `cycle`.

Determin whether such paths and cycles exist in graph is the `Hamiltonian path problem`, which is `NP-complete`.

![Hamiltonian](/images/2020-02-15-Eulerian-Path-And-Hamiltonian-Cycle/Hamiltonian.png)

#### Reference

<https://en.wikipedia.org/wiki/Eulerian_path>

<https://en.wikipedia.org/wiki/Hamiltonian_path>

<https://www.geeksforgeeks.org/eulerian-path-and-circuit/>
