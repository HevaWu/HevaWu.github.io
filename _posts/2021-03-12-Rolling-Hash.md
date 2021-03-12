---
layout: post
title: Rolling Hash
date: 2021-03-12 18:58:00
comment_id: 142
categories: [Algorithm]
tags: [hash]
---

> A rolling hash (also known as recursive hashing or rolling checksum) is a hash function where the input is hashed in a window that moves through the input.
>
> A few hash functions allow a rolling hash to be computed very quickly—the new hash value is rapidly calculated given only the old hash value, the old value removed from the window, and the new value added to the window—similar to the way a moving average function can be computed much more quickly than other low-pass filters.

Some Usage Examples:

- `Rabin–Karp string search` algorithm
- `rsync` program, which uses a checksum based on Mark Adler's adler-32 as its rolling hash
- `Low Bandwidth Network Filesystem (LBFS)` uses a Rabin fingerprint as its rolling hash
- `FastCDC` (Fast Content-Defined Chunking) uses a compute-efficient Gear fingerprint as its rolling hash.

## Rabin fingerprint

Seen a polynomial of bits. The hash is result of the division of that polynomial by an irreducible polynomial over GF(2). It's possible to update Rabin fingerprint using only entering and leaving byte.

## Cyclic polynomial

Befefit of avoiding multiplications. It is a form of tabulation hashing:

It presumes that there is some hash function $h$ from characters to integers in the interval $[0,2^{L})$. This hash function might be simply an array or a hash table mapping characters to random integers. Let the function $s$ be a cyclic binary rotation (or circular shift): it rotates the bits by 1 to the left, pushing the latest bit in the first position. E.g., $s(101)=011$ $s(101)=011$. Let $\oplus$ be the bitwise exclusive or. The hash values are defined as

$$
H=s^{k-1}(h(c_{1}))\oplus s^{k-2}(h(c_{2}))\oplus \ldots \oplus s(h(c_{k-1}))\oplus h(c_{k})
$$

where the multiplications by powers of two can be implemented by binary shifts. The result is a number in $[0,2^{L})$.

Computing the hash values in a rolling fashion is done as follows. Let $H$ be the previous hash value. Rotate $H$ once: $ H\leftarrow s(H)$. If $ c_{1}$ is the character to be removed, rotate it $k$ times: $s^{k}(h(c_{1}))$. Then simply set

$$
H\leftarrow s(H)\oplus s^{k}(h(c_{1}))\oplus h(c_{k+1})
$$

where $ c_{k+1}$ is the new character.

Hashing by cyclic polynomials is strongly universal or pairwise independent: simply keep the first $ L-k+1$ bits. That is, take the result $H$ and dismiss any $k-1$ consecutive bits. In practice, this can be achieved by an integer division $ H\rightarrow H\div 2^{k-1}$.

## Content-based slicing using a rolling hash

> One of the interesting use cases of the rolling hash function is that it can create dynamic, content-based chunks of a stream or file. This is especially useful when it is required to send only the changed chunks of a large file over a network and a simple byte addition at the front of the file would cause all the fixed size windows to become updated, while in reality, only the first "chunk" has been modified.
>
> The simplest approach to calculate the dynamic chunks is to calculate the rolling hash and if it matches a pattern (like the lower N bits are all zeroes) then it’s a chunk boundary. This approach will ensure that any change in the file will only affect its current and possibly the next chunk, but nothing else.
>
> When the boundaries are known, the chunks need to be compared by their hash values to detect which one was modified and needs transfer across the network. The backup software Attic uses a Buzhash algorithm with a customizable chunk size range for splitting file streams.

## Content-based slicing using moving sum

$$
S(n)=\sum_{i=n-8195}^{n}c_{i} \\
H(n)=S(n) \mod 4096
$$

where

- $S(n)$ is the sum of 8196 consecutive bytes ending with byte $n$ (requires 21 bits of storage),
- $c_{i}$ is byte $i$ of the file,
- $H(n)$ is a "hash value" consisting of the bottom 12 bits of $S(n)$.

Shifting the window by one byte simply involves adding the new character to the sum and subtracting the oldest character (no longer in the window) from the sum.

For every $n$ where $ H(n)==0$, these programs cut the file between $n$ and $n+1$. This approach will ensure that any change in the file will only affect its current and possibly the next chunk, but no other chunk.

#### References

- <https://en.wikipedia.org/wiki/Rolling_hash>
