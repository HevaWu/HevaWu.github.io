---
layout: post
title: HashMap vs HashSet
date: 2019-09-13 17:52:00
comments: true
disqus_category_id: HashMapvsHashSet
categories: [Java]
tags: [HashMap, HashSet, Map, Set]
---

The obvious difference between `HashMap` & `HashSet` would be interface.

- HashSet is an implementation of Set Interface which does not allow duplicate value. Objects that are stored in HashSet must override equals() for checking equality and hashCode() methods for no duplicate value are stored in our set.
- HashMap is an implementaion of Map Interface which map a key to value. Duplicate keys are not allowed in a map. Map Interface has 2 implementation classes: HashMap, TreeMap. The main difference is TreeMap maintains order of the objects but HashMap will not. HashMap allows null values and null keys.

### Note

- HashMap is faster than HashSet.
- Dummy value: HashMap doesn't have concept of dummy value, HashSet internally uses HashMap to add elements. In HashSet, java internally associates dummy value for each value passed in add(Object) method.
- Storing or Adding mechanism: HashMap internally uses hashing to store or add objects. HashSet internally uses HashMap object to store or add objects.

### Map & HashMap

No difference between the objects. We could set `HashMap<String, Object>` in both cases.

The advantage to use `Map<String, Object>` is that you can change the object to be a different kind of map without breaking the contract with any code that's using. If we declare it as `HashMap<String, Object>`, it is needed to change the contract code if we want to change the underlying implementation.

Interfaces (and base classes) let us reveal `only as  much as is necessary`, keeping our flexibility under the covers to make changes as appropriate. In general, we want to have our references be as basic as possible. If we don't need to know its a `HashMap`, just call it a `Map`.

Same for Set & HashSet.

#### Reference

https://www.geeksforgeeks.org/difference-between-hashmap-and-hashset/
https://stackoverflow.com/a/1348228