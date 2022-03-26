---
layout: post
title: Reservoir Sampling
date: 2022-01-08 22:18:00
comment_id: 201
categories: [Algorithm]
tags: [Sampling]
---

**Reservoir sampling** is a family of randomized algorithms for **choosing a simple random sample, without replacement, of k items from a population of `unknown size n` in a single pass over the items**.

The size of the population `n is not known` to the algorithm and is typically too large for all n items to fit into main memory. The population is revealed to the algorithm over time, and the algorithm cannot look back at previous items. **The problem is that we do not always know the exact n in advance**.

At any point, the current state of the algorithm must permit extraction of a simple random sample without replacement of size k over the part of the population seen so far.

## Algorithm R (Simple algorithm)

1. maintaining a reservoir of size $k$, which initially contains the first $k$ items of the input.
2. iterates over the remaining items until the input is exhausted.
   1. Using one-based array indexing, let $i>k$ be the index of the item currently under consideration.
   2. generates a random number $j$ between (and including) 1 and $i$.
   3. If $j$ is at most $k$, then the item is selected and replaces whichever item currently occupies the $j-th$ position in the reservoir.
   4. Otherwise, the item is discarded.
   5. In effect, for all i, the ith element of the input is chosen to be included in the reservoir with probability $k/i$. Similarly, at each iteration the $jth$ element of the reservoir array is chosen to be replaced with probability $1/k * k/i=1/i$. It can be shown that when the algorithm has finished executing, each item in the input population has equal probability (i.e., $k/n$) of being chosen for the reservoir: $k/i * (1-1/(i+1)) * (1-1/(i+2)) * (1-1/(i+3)) * ... * (1-1/n)=k/n$.

### Pseudocode

Time Complexity: O(n)

```s
(* S has items to sample, R will contain the result *)
ReservoirSample(S[1..n], R[1..k])
  // fill the reservoir array
  for i := 1 to k
      R[i] := S[i]

  // replace elements with gradually decreasing probability
  for i := k+1 to n
    (* randomInteger(a, b) generates a uniform integer from the inclusive range {a, ..., b} *)
    j := randomInteger(1, i)
    if j <= k
        R[j] := S[i]
```

## Algorithm L (An optimal algorithm)

Time Complexity: $O(k(1+log(n/k)))$

```s
(* S has items to sample, R will contain the result *)
ReservoirSample(S[1..n], R[1..k])
  // fill the reservoir array
  for i = 1 to k
      R[i] := S[i]

  (* random() generates a uniform (0,1) random number *)
  W := exp(log(random())/k)

  while i <= n
      i := i + floor(log(random())/log(1-W)) + 1
      if i <= n
          (* replace a random item of the reservoir with item i *)
          R[randomInteger(1,k)] := S[i]  // random index between 1 and k, inclusive
          W := W * exp(log(random())/k)
```

#### References

- <https://en.wikipedia.org/wiki/Reservoir_sampling#cite_note-vitter-1>
