---
layout: post
title: Hash Table
date: 2020-02-02 16:51:00
comments: true
disqus_category_id: HashTable
categories: [DataStructure, Swift, Java, C++]
tags: [Collection]
---

## Overview

> `Hash Table` is a data structure that implements an associative array abstract data type, a structure that can map keys and values. A hash table uses a hash function to compute an index, also called a *hash code*, into an array of *buckets* or *slots*, from which the desired value can be found.

Idealy, hash function will assign each key to a unique bucket, but most hash table designs are not perfect, which might cause hash collisions.

For collision, there are some common strategies described below.

## Collison Solution

### Seperate chaining

> Each bucket is independent, and has some sort of list of entries with the same index. The time for hash table operations is the time to find the bucket (which is constant) plus the time for the list operation.

```
Chained-Hash-Insert(T,x)
insert x at the head of list T[h(x.key)]

Chained-Hash-Search(T,k)
search for an element with key k in list T[h(k)]

Chained-Hash-Delete(T,x)
delete x from the list T[h(x.key)]
```

The worst case for insertion is `O(1)`, if the list is `Doubly linked list`, then delete one element could also be in `O(1)`. If the list is `Singly linked list`, for deleting one element, we need to first search the element in T[h(x.key)], then change the previous element.next property to delete x from list. So, under `Singly linked list`, the time complexity of delete and search are almost same.

For a list which could store n element, and have m slots. Give it a load factor `a = n/m`. For the worst case of chained hash table: all of n.key are in same slot, which will have a list with length of n. At this time, the worst searching time would be `O(n)`.

The average performance of hash table depends on hash function h, the average degree that it will assign element into m slots. For now, we suppose one element could be averagely assigned into m slots and have no effect on other elements assignment -> `Simple uniform Hashing`. If slot number m is in direct ratio to element number n, n = O(m), a = n/m = O(m)/m = O(1). So Search time complexity will be `O(1)`, when linked list is `doubly linked list`, the worst case of insertion will be `O(1)`, delete is also take `O(1)`. Thus, all of operation could be token in `O(1)`.
 
In a good hash table, each bucket has zero or one entries, and sometimes two or three, but rarely more than that. Therefore, structures that are efficient in time and space for these cases are preferred. Structures that are efficient for a faily large number of entries per bucket are not needed or desirable. If these cases happen often, the hashing function needs to be fixed.

### Open Addressing

> All entry records are stored in the bucket array itself. When a new entry has to be inserted, the buckets are examined, starting with the hashed-to slot and proceeding in some probe sequence, until an unoccupied slot is found. When searching for an entry, the buckets are scanned in the same sequence, until either the target record is found, or an unused array slot is found, which indicates that there is no such key in the table.

```
Open-Address-Hash-Insert(T,k)
i = 0
repeat
    j = h(k,i)
    if T[j] == NIL
        T[j] = k
        return j
    else i = i+1
until i == m
error "hash table overflow"

Open-Address-Hash-Search(T,k)
i = 0
repeat
    j = h(k,i)
    if T[j] == k
        return j
    i = i+1
until T[j] == NIL or i == m
return NIL
```

It is hard to DELETE element by using open addressing, since current slot cannot be empty. So, for application must have DELETE operation, `Seperate chaining` is a better way. 

## Hash Function

Feature of nice hash function:

- Each elements should be assigned into any of m solts randomly, and have no effect on other element.

### Division hashing

```
h(k) = k mod m
```

*Note: avoid to select exponentiation of 2 as m.* We often select a prime number which not closed to 2's exponentiation as m.

### Multiplication hashing

![multiplicationhashing](/images/2020-02-02-Hash-Table/multiplicationhashing.png#simulator)

One of its benefit is m is so important, normally, `m = 2^p`

### Universal hasing

Select hash function at random from a family of hash functions with certain mathematical property. THis guarantees a low number of collisions in expectation. Everytime the result will be different, even for the same input.

## Direct Address Table

For short array, `Direct-Address Table` is simple and efficient way. ex: 

All of the element is from U = {0, 1, ..., m-1}, built a table `T[0..m-1]`. Each T[i] represent one of U element. U[i] = k, T[k] = k.
If there is no index i value is k, then T[k] = NIL.

```
Direct-Address-Search(T,k)
return T[k]

Direct-Address-Insert(T,x)
T[x.key] = x

Direct-Address-Delete(T,x)
T[x.key] = NIL
```

All of the operation above take `O(1)` time. The shortcoming of this method is obvious. If U is very large, it would be hard to or impossible to be stored into a standard computer. Also, the real keys K might smaller than U, which waste lots of space in T. That's why we recommended to use `Hash Table` for this case.

## Programming Language

- Java: [HashTable](https://docs.oracle.com/javase/8/docs/api/java/util/Hashtable.html)
- C++: [unordered_map](http://www.cplusplus.com/reference/unordered_map/unordered_map/)
- Swift: not directly have this structure, but could built with `Dictionary`

#### Reference

<https://en.wikipedia.org/wiki/Hash_table>

<https://docs.oracle.com/javase/8/docs/api/java/util/Hashtable.html>

<http://www.cplusplus.com/reference/unordered_map/unordered_map/>
