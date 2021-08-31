---
layout: post
title: Tarjan's strongly connected components algorithm
date: 2021-04-24 22:02:00
comment_id: 151
categories: [Algorithm]
tags: [Graph]
---

> `Tarjan's strongly connected components algorithm` is an algorithm in graph theory for `finding the strongly connected components (SCCs)` of a `directed graph`. It runs in linear time, matching the time bound for alternative methods including Kosaraju's algorithm and the path-based strong component algorithm.

Algorithm take a directed graph as input, and produces a partition of the graph's vertices into the graph's strongly connected components. Each vertex of the graph appears in exactly one of the strongly connected components.

> The basic idea of the algorithm is this: a depth-first search (DFS) begins from an arbitrary start node (and subsequent depth-first searches are conducted on any nodes that have not yet been found). As usual with depth-first search, the search visits every node of the graph exactly once, declining to revisit any node that has already been visited.
>
> The basic idea of the algorithm is this: a depth-first search (DFS) begins from an arbitrary start node (and subsequent depth-first searches are conducted on any nodes that have not yet been found). As usual with depth-first search, the search visits every node of the graph exactly once, declining to revisit any node that has already been visited.

1. DFS search produces a DFS tree/forest
2. Strongly Connected Components form subtrees of the DFS tree.
3. If we can find the head of such subtrees, we can print/store all the nodes in that subtree (including head) and that will be one SCC.
4. There is no back edge from one SCC to another (There can be cross edges, but cross edges will not be used while processing the graph).

We could keep track `index` and `low` for each node.

- **index**: time when a node is visited while DFS traversal
- **low**: dfs tree lowest ancestor node

For any node $u$, when DFS starts, $low[u]$ will be set as $index[u]$, later on DFS will performed each of its children $v$ one by one. $low[u]$ can change in 2 case:

- case 1(Tree Edge): if node $v$ is not visited already, then after DFS of $v$ is complete. $low[u] = min(low[u], low[v])$
- case 2(Back Edge): when child $v$ already visited, $low[u] = min(low[u], index[v])$

## Pseudocode

```sh
algorithm tarjan is
    input: graph G = (V, E)
    output: set of strongly connected components (sets of vertices)

    index := 0
    S := empty stack
    for each v in V do
        if v.index is undefined then
            strongconnect(v)
        end if
    end for

    function strongconnect(v)
        // Set the depth index for v to the smallest unused index
        v.index := index
        v.lowlink := index
        index := index + 1
        S.push(v)
        v.onStack := true

        // Consider successors of v
        for each (v, w) in E do
            if w.index is undefined then
                // Successor w has not yet been visited; recurse on it
                strongconnect(w)
                v.lowlink := min(v.lowlink, w.lowlink)
            else if w.onStack then
                // Successor w is in stack S and hence in the current SCC
                // If w is not on stack, then (v, w) is an edge pointing to an SCC already found and must be ignored
                // Note: The next line may look odd - but is correct.
                // It says w.index not w.lowlink; that is deliberate and from the original paper
                v.lowlink := min(v.lowlink, w.index)
            end if
        end for

        // If v is a root node, pop the stack and generate an SCC
        if v.lowlink = v.index then
            start a new strongly connected component
            repeat
                w := S.pop()
                w.onStack := false
                add w to current strongly connected component
            while w ≠ v
            output the current strongly connected component
        end if
    end function
```

## Complexity

- **Time Complexity**: The Tarjan procedure is called once for each node; the forall statement considers each edge at most once. The algorithm's running time is therefore linear in the number of edges nodes in G, i.e. $\displaystyle O(\|V\|+\|E\|)$.
- **Space Complexity**: The Tarjan procedure requires two words of supplementary data per vertex for the index and lowlink fields, along with one bit for onStack and another for determining when index is undefined. In addition, one word is required on each stack frame to hold v and another for the current position in the edge list.
  - the worst-case size of the stack S must be $\|V\|$ (i.e. when the graph is one giant component). This gives a final analysis of $\|V\| \cdot (2+5w)$ where $w$ is the machine word size. The variation of Nuutila and Soisalon-Soininen reduced this to $O(\|V\| \cdot (1+4w))$ and, subsequently, that of Pearce requires only $O(\|V\|\cdot (1+3w))$.

#### Reference

- <https://en.wikipedia.org/wiki/Tarjan%27s_strongly_connected_components_algorithm>
- <https://www.geeksforgeeks.org/tarjan-algorithm-find-strongly-connected-components/>
