---
layout: post
title: Topological Sort
date: 2020-02-15 13:40:00
comment_id: 51
categories: [Algorithm]
tags: [Sort, DAG]
---

For a directed acyclic graph(DAG) `G = (V, E)`, topological sort is a sort for all of node in G. The order should be:

- if Gragh G contains (u,v) edge, then node u in topological sort should be at the former of node v.

## Pseudocode

```
// TOPOLOGICAL-SORT(G)
call DFS(G) to compute finishing times v.f for each vertex v
as each vertex is finished, insert it onto the front of a linked list
return the linked list of vertices
```

We could implement it in `O(V+E)` <- which is the DFS time complexity.
