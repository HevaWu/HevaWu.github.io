---
layout: post
title: Rabin–Karp algorithm
date: 2021-03-28 16:57:00
comment_id: 147
categories: [Algorithm]
tag: [String]
---

> Rabin–Karp algorithm or Karp–Rabin algorithm is a `string-searching` algorithm that uses `hashing` to find `an exact match of a pattern string` in a text. It uses a `rolling hash` to quickly filter out positions of the text that cannot match the pattern, and then checks for a match at the remaining positions. Generalizations of the same idea can be used to find more than one match of a single pattern, or to find matches for more than one pattern.
>
> To find a `single match` of a single pattern, the expected time of the algorithm is `linear in the combined length of the pattern and text`, although its `worst-case` time complexity is the `product of the two lengths`. To find multiple matches, the expected time is linear in the input lengths, plus the combined length of all the matches, which could be greater than linear.

## Pseudocode

```sh
function RabinKarp(string s[1..n], string pattern[1..m])
    hpattern := hash(pattern[1..m]);
    for i from 1 to n-m+1
        hs := hash(s[i..i+m-1])
        if hs = hpattern
            if s[i..i+m-1] = pattern[1..m]
                return i
    return not found

# rolling hash
s[i+1..i+m] = s[i..i+m-1] - s[i] + s[i+m]

# Multiple pattern search
function RabinKarpSet(string s[1..n], set of string subs, m):
    set hsubs := emptySet
    foreach sub in subs
        insert hash(sub[1..m]) into hsubs
    hs := hash(s[1..m])
    for i from 1 to n-m+1
        if hs ∈ hsubs and s[i..i+m-1] ∈ subs
            return i
        hs := hash(s[i+1..i+m])
    return not found
```

#### References

- <https://en.wikipedia.org/wiki/Rabin%E2%80%93Karp_algorithm>
