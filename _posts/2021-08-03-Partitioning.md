---
layout: post
title: Ch06 Partitioning
date: 2021-08-03 18:52:00
comment_id: 183
categories: [Data Systems, System Design]
tags: [Designing Data Intensive Applications]
---

`partitions` (`sharding`): each piece of data (each record, row, or document) belongs to exactly one partition.

The main reason for wanting to partition data is `scalability`. Different partitions can be placed on different nodes in a shared-nothing cluster. Thus, a large dataset can be distributed across many disks, and the query load can be distributed across many processors.

# Partitioning and Replication

Partitioning is usually combined with replication so that copies of each partition are stored on multiple nodes. This means that, `even though each record belongs to exactly one partition, it may still be stored on several different nodes for fault tolerance`.

The choice of partitioning scheme is mostly independent of the choice of replication scheme.

# Partitioning of Key-Value Data

Goal with partitioning is to spread the data and the query `load evenly` across nodes.

- `skewed`: If the partitioning is unfair, so that some partitions have more data or queries than others
- `hot spot`: A partition with disproportionately high load

The simplest approach for avoiding hot spots would be to assign records to nodes `randomly`. But it has a big `disadvantage`: when you’re trying to read a particular item, you have no way of knowing which node it is on, so you have to query all nodes in parallel.

## Partitioning by Key Range

The ranges of keys are not necessarily evenly spaced, because your data may not be evenly distributed. In order to distribute the data evenly, the partition boundaries need to adapt to the data.

Within each partition, we can keep keys in sorted order.

- advantages: range scans are easy, and you can treat the key as a concatenated index in order to fetch several related records in one query
- downside: certain access patterns can lead to hot spots. If the key is a timestamp, then the partitions correspond to ranges of time. To avoid this problem in the sensor database, you need to use something other than the timestamp as the first element of the key.

## Partitioning by Hash of Key

Once you have a suitable hash function for keys, you can assign each partition a range of hashes (rather than a range of keys), and every key whose hash falls within a partition’s range will be stored in that partition.

- advantages: distributing keys fairly among the partitions. The partition boundaries can be evenly spaced, or they can be chosen pseudorandomly (in which case the technique is sometimes known as `consistent hashing`) (`hash partitioning`).
- downside: lose the ability to do efficient range queries. Keys that were once adjacent are now scattered across all the partitions, so their sort order is lost.

`consistent hashing`: a way of evenly distributing load across an internet-wide system of caches such as a content delivery network (CDN). It uses randomly chosen partition boundaries to avoid the need for central control or distributed consensus.

## Skewed Workloads and Relieving Hot Spots

If one key is known to be very hot, a simple technique is to add a random number to the beginning or end of the key. `Just a two-digit decimal random number would split the writes to the key evenly` across 100 different keys, allowing those keys to be distributed to different partitions.

This technique also requires additional bookkeeping: it only makes sense to append the random number for the small number of hot keys; for the vast majority of keys with low write throughput this would be unnecessary overhead. Thus, you also need some way of `keeping track of which keys are being split`.

# Partitioning and Secondary Indexes

A `secondary index` usually doesn’t identify a record uniquely but rather is a way of searching for occurrences of a particular value.

The problem with secondary indexes is that `they don’t map neatly to partitions`. Two main approaches to partitioning a database with secondary indexes: `document-based partitioning` and `term-based partitioning`.

## Partitioning Secondary Indexes by Document

Dach partition maintains its own secondary indexes, covering only the documents in that partition. It doesn’t care what data is stored in other partitions. Whenever you write to the database—to add, remove, or update a document—you only need to deal with the partition that contains the document ID that you are writing. For that reason, a document-partitioned index is also known as a `local index` (as opposed to a `global index`.

`scatter/gather`: if we want to search with secondary index, need to send the query to all partitions, and combine all the results get back.

Even if you query the partitions in parallel, scatter/gather is prone to tail latency amplification.

## Partitioning Secondary Indexes by Term

`index term-partitioned`, the term we’re looking for determines the partition of the index. The name term comes from full-text indexes (a particular kind of secondary index), where the terms are all the words that occur in a document.

We can partition the index by the term itself, or using a hash of the term.
- Partitioning by the term itself: useful for range scans
- Partitioning on a hash of the term: gives a more even distribution of load.

The `advantage` of a global (term-partitioned) index over a document-partitioned index is that it can make reads more efficient: rather than doing scatter/gather over all partitions, a client only needs to make a request to the partition containing the term that it wants.

The `downside` of a global index is that writes are slower and more complicated, because a write to a single document may now affect multiple partitions of the index (every term in the document might be on a different partition, on a different node).

# Rebalancing Partitions

Why require rebalancing:

- The query throughput increases, so you want to add more CPUs to handle the load.
- The dataset size increases, so you want to add more disks and RAM to store it.
- A machine fails, and other machines need to take over the failed machine’s responsibilities.

`rebalancing`: The process of moving load from one node in the cluster to another

rebalancing is usually expected to meet some minimum requirements:

- After rebalancing, the `load` (data storage, read and write requests) should be `shared fairly` between the nodes in the cluster.
- While rebalancing is happening, `the database should continue accepting reads and writes`.
- `No more data than necessary should be moved` between nodes, to make rebalancing fast and to minimize the network and disk I/O load.

## Strategies for Rebalancing

### Why not do mod N

The `problem` with the `mod N` approach is that if the number of nodes N changes, most of the keys will need to be moved from one node to another. Such frequent moves make rebalancing excessively expensive.

### Fixed number of partitions

Create many more partitions than there are nodes, and assign several partitions to each node. If a node is added to the cluster, the new node can steal a few partitions from every existing node until partitions are fairly distributed once again. `Only entire partitions are moved between nodes. The number of partitions does not change`, nor does the assignment of keys to partitions.

In principle, you can even account for mismatched hardware in your cluster: by assigning more partitions to nodes that are more powerful, you can force those nodes to take a greater share of the load. The number of partitions is usually fixed when the database is first set up and not changed afterward. Choosing the right number of partitions is difficult if the total size of the dataset is highly variable (for example, if it starts small but may grow much larger over time).

### Dynamic partitioning

`dynamic partitioning`: When a partition grows to exceed a configured size (on HBase, the default is 10 GB), it is split into two partitions so that approximately half of the data ends up on each side of the split. Conversely, if lots of data is deleted and a partition shrinks below some threshold, it can be merged with an adjacent partition.

An `advantage` of dynamic partitioning is that the number of partitions adapts to the total data volume.

A `caveat` is that an empty database starts off with a single partition, since there is no a priori information about where to draw the partition boundaries.

`pre-splitting`: an initial set of partitions to be configured on an empty database.

# Request Routing

`service discovery`:  if I want to read or write the key “foo”, which IP address and port number do I need to connect to?

- Allow clients to contact any node (e.g., via a round-robin load balancer). If that node coincidentally owns the partition to which the request applies, it can handle the request directly; otherwise, it forwards the request to the appropriate node, receives the reply, and passes the reply along to the client.
- Send all requests from clients to a routing tier first, which determines the node that should handle each request and forwards it accordingly. This routing tier does not itself handle any requests; it only acts as a partition-aware load balancer.
- Require that clients be aware of the partitioning and the assignment of partitions to nodes. In this case, a client can connect directly to the appropriate node, without any intermediary.

Many distributed data systems rely on a separate coordination service such as ZooKeeper to keep track of this cluster metadata. Each node registers itself in ZooKeeper, and ZooKeeper maintains the authoritative mapping of partitions to nodes. Other actors, such as the routing tier or the partitioning-aware client, can subscribe to this information in ZooKeeper. Whenever a partition changes ownership, or a node is added or removed, ZooKeeper notifies the routing tier so that it can keep its routing information up to date.

When using a routing tier or when sending requests to a random node, clients still need to find the IP addresses to connect to. These are not as fast-changing as the assignment of partitions to nodes, so it is often sufficient to use DNS for this purpose.

## Parallel Query Execution

`massively parallel processing (MPP)` relational database products, often used for analytics, are much more sophisticated in the types of queries they support. A typical data warehouse query contains several join, filtering, grouping, and aggregation operations. The MPP query optimizer breaks this complex query into a number of execution stages and partitions, many of which can be executed in parallel on different nodes of the database cluster. Queries that involve scanning over large parts of the dataset particularly benefit from such parallel execution.

# Summary

2 main partitioning:

- `Key range partitioning`,
  - where keys are sorted, and a partition owns all the keys from some minimum up to some maximum. Sorting has the advantage that efficient range queries are possible, but there is a risk of hot spots if the application often accesses keys that are close together in the sorted order.
  - In this approach, partitions are typically rebalanced dynamically by splitting the range into two subranges when a partition gets too big.
- `Hash partitioning`,
  - where a hash function is applied to each key, and a partition owns a range of hashes. This method destroys the ordering of keys, making range queries inefficient, but may distribute load more evenly.
  - When partitioning by hash, it is common to create a fixed number of partitions in advance, to assign several partitions to each node, and to move entire partitions from one node to another when nodes are added or removed. Dynamic partitioning can also be used.

2 method interaction between partitioning and secondary indexes:

- `Document-partitioned indexes (local indexes)`, where the secondary indexes are stored in the same partition as the primary key and value. This means that only a single partition needs to be updated on write, but a read of the secondary index requires a scatter/gather across all partitions.
- `Term-partitioned indexes (global indexes)`, where the secondary indexes are partitioned separately, using the indexed values. An entry in the secondary index may include records from all partitions of the primary key. When a document is written, several partitions of the secondary index need to be updated; however, a read can be served from a single partition.

#### References

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch06.html>
