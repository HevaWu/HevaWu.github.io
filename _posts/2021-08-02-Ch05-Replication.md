---
layout: post
title: Ch05 Replication
date: 2021-08-02 18:20:00
comment_id: 182
categories: [Data Systems, System Design]
---

`Replication` means keeping a copy of the same data on multiple machines that are connected via a network. Reasons why we should keep:

- To keep data geographically close to your users (and thus reduce access latency)
- To allow the system to continue working even if some of its parts have failed (and thus increase availability)
- To scale out the number of machines that can serve read queries (and thus increase read throughput)

All of the `difficulty` in replication lies in `handling changes` to replicated data. Three popular algorithms for replicating changes between nodes: `single-leader`, `multi-leader`, and `leaderless` replication.

There are many `trade-offs` to consider with replication: for example, whether to use synchronous or asynchronous replication, and how to handle failed replicas.

# Leaders and Followers

Each node that stores a copy of the database is called a `replica`. Every write to the database needs to be processed by every replica; otherwise, the replicas would no longer contain the same data. The most common solution for this is called `leader-based` replication (also known as `active/passive` or `master–slave` replication). It works as follows:

- One of the replicas is designated the `leader` (also known as master or primary). When `clients want to write to the database, they must send their requests to the leader`, which first writes the new data to its local storage.
- The other replicas are known as `followers` (read replicas, slaves, secondaries, or hot standbys).i Whenever the `leader writes new data` to its local storage, it also `sends the data change to all of its followers` as part of a `replication log or change stream`. Each follower takes the log from the leader and updates its local copy of the database accordingly, by applying all writes in the same order as they were processed on the leader.
- When a client wants to read from the database, it can query either the leader or any of the followers. However, `writes are only accepted on the leader` (the followers are read-only from the client’s point of view).

## Synchronous vs Asynchronous Replication

The `advantage` of `synchronous` replication is that the f`ollower is guaranteed to have an up-to-date copy` of the data that is consistent with the leader. If the leader suddenly fails, we can be sure that the data is still available on the follower. The `disadvantage` is that `if the synchronous follower doesn’t respond` (because it has crashed, or there is a network fault, or for any other reason), `the write cannot be processed`. The leader must block all writes and wait until the synchronous replica is available again.

`semi-synchronous`: if you enable synchronous replication on a database, it usually means that one of the followers is synchronous, and the others are asynchronous. If the synchronous follower becomes unavailable or slow, one of the asynchronous followers is made synchronous. This guarantees that you have an up-to-date copy of the data on at least two nodes: the leader and one synchronous follower.

`leader-based` replication is configured to be completely `asynchronous`. In this case, `if the leader fails and is not recoverable, any writes that have not yet been replicated to followers are lost`. This means that a `write is not guaranteed to be durable`, even if it has been confirmed to the client. However, a fully asynchronous configuration has the `advantage` that the `leader can continue processing writes, even if all of its followers have fallen behind`. `Asynchronous replication is nevertheless widely used`, especially if there are many followers or if they are geographically distributed.

`Chain replication` is a variant of synchronous replication that has been successfully implemented in a few systems such as Microsoft Azure Storage. There is a `strong connection between consistency of replication and consensus` (getting several nodes to agree on a value).

## Setting Up New Followers

Set up new followers—perhaps to increase the number of replicas, or to replace failed nodes. Here is the process:

- Take a `consistent snapshot` of the leader’s database at some point in time—if possible, `without taking a lock on the entire database`. Most databases have this feature, as it is also required for backups. In some cases, third-party tools are needed, such as `innobackupex` for MySQL
- `Copy the snapshot` to the new follower node.
- The follower connects to the leader and requests all the data changes that have happened since the snapshot was taken. This requires that the `snapshot is associated with an exact position` in the leader’s replication log. That position has various names: for example, PostgreSQL calls it the `log sequence number`, and MySQL calls it the `binlog coordinates`.
- When the follower has processed the backlog of data changes since the snapshot, we say it has `caught up`. It can now continue to process data changes from the leader as they happen.

## Handling Node Outages

- Follower failure: Catch-up recovery
  - On its local disk, each follower keeps a log of the data changes it has received from the leader. If a follower crashes and is restarted, or if the network between the leader and the follower is temporarily interrupted, the follower can recover quite easily: `from its log`, `it knows the last transaction that was processed before the fault occurred`. Thus, the `follower can connect to the leader and request all the data changes that occurred during the time when the follower was disconnected`. When it has applied these changes, it has caught up to the leader and can continue receiving a stream of data changes as before.
- Leader failure: Failover
  - `failover`: one of the followers needs to be promoted to be the new leader, clients need to be reconfigured to send their writes to the new leader, and the other followers need to start consuming data changes from the new leader.
  - failover can happen manually or automatically
  - automatically process:
    - **Determining that the leader has failed**. use a timeout: nodes frequently bounce messages back and forth between each other, and if a node doesn’t respond for some period of time, it is assumed to be dead.
    - **Choosing a new leader**. election process: by `majority of the remaining replicas` or by previously elected `controller node`. The best candidate for leadership is usually the replica with the `most up-to-date data changes from the old leader` (to minimize any data loss). Getting all the nodes to agree on a new leader is a `consensus` problem.
    - **Reconfiguring the system to use the new leader**. If the old leader comes back, the system needs to ensure that the old leader becomes a follower and recognizes the new leader.

## Implementation of Replication Logs

### Statement-based replication

The leader logs every write request (statement) that it executes and sends that statement log to its followers. Some problems:

- Any statement that calls a nondeterministic function, such as `NOW()` to get the current date and time or `RAND()` to get a random number, is likely to `generate a different value` on each replica.
- If statements use an autoincrementing column, or if they depend on the existing data in the database (e.g., UPDATE … WHERE <some condition>), they must be executed in `exactly the same order` on each replica, or else they may have a different effect. This can be limiting when there are multiple concurrently executing transactions.
- Statements that have side effects (e.g., triggers, stored procedures, user-defined functions) may result in different side effects occurring on each replica, unless the side effects are absolutely deterministic.

By default MySQL now switches to `row-based replication` if there is any nondeterminism in a statement. VoltDB uses statement-based replication, and makes it safe by `requiring transactions to be deterministic`.

### Write-ahead log (WAL) shipping

- In the case of a `log-structured storage engine,` this log is the `main place for storage`. Log segments are compacted and garbage-collected in the background.
- In the case of a `B-tree`, which `overwrites individual disk blocks`, every modification is first written to a write-ahead log so that the index can be restored to a consistent state after a crash.

The log is an append-only sequence of bytes containing all writes to the database. The main `disadvantage` is that the l`og describes the data on a very low level`: a WAL contains details of which bytes were changed in which disk blocks. This makes replication closely coupled to the storage engine.` If the database changes its storage format from one version to another, it is typically not possible to run different versions of the database software on the leader and the followers`.

### Logical (row-based) log replication

`logical log`:  use different log formats for replication and for the storage engine, which allows the replication log to be decoupled from the storage engine internals

- For an inserted row, the log contains the new values of all columns.
- For a deleted row, the log contains enough information to uniquely identify the row that was deleted. Typically this would be the primary key, but if there is no primary key on the table, the old values of all columns need to be logged.
- For an updated row, the log contains enough information to uniquely identify the updated row, and the new values of all columns (or at least the new values of all columns that changed).

Benefits:

- allowing the leader and the follower to run different versions of the database software, or even different storage engines.
- easier for external applications to parse (`change data capture`)

### Trigger-based replication

`Triggers and stored procedures`: A trigger lets you register custom application code that is automatically executed when a data change (write transaction) occurs in a database system. The trigger has the opportunity to log this change into a separate table, from which it can be read by an external process. That external process can then apply any necessary application logic and replicate the data change to another system.

# Problems with Replication Lag

Leader-based replication requires `all writes to go through a single node, but read-only queries can go to any replica`. For workloads that consist of mostly reads and only a small percentage of writes (a common pattern on the web), there is an attractive option: `create many followers, and distribute the read requests across those followers.` This removes load from the leader and allows read requests to be served by nearby replicas.

`eventual consistency`: if you run the same query on the leader and a follower at the same time, you may get different results, because not all writes have been reflected in the follower. This inconsistency is just a temporary state—if you stop writing to the database and wait a while, the followers will eventually catch up and become consistent with the leader.

`replication lag`:  the delay between a write happening on the leader and being reflected on a follower

## Reading Your Own Writes

When new data is submitted, it must be sent to the leader, but when the user views the data, it can be read from a follower. If the user views the data shortly after making a write, the new data may not yet have reached the replica. To the user, it looks as though the data they submitted was lost, so they will be understandably unhappy.

`read-after-write` consistency, also known as `read-your-writes` consistency: `guarantee that if the user reloads the page, they will always see any updates they submitted themselves`. It makes no promises about other users: other users’ updates may not be visible until some later time. However, it reassures the user that their own input has been saved correctly.

- When reading something that the user may have modified, read it from the leader; otherwise, read it from a follower.
- track the time of the last update and, for one minute after the last update, make all reads from the leader. You could also monitor the replication lag on followers and prevent queries on any follower that is more than one minute behind the leader.
- The client can remember the timestamp of its most recent write—then the system can ensure that the replica serving any reads for that user reflects updates at least until that timestamp.
- If your replicas are distributed across multiple datacenters (for geographical proximity to users or for availability), there is additional complexity. Any request that needs to be served by the leader must be routed to the datacenter that contains the leader.

`cross-device read-after-write consistency`: f the user enters some information on one device and then views it on another device, they should see the information they just entered.

- Approaches that require remembering the `timestamp` of the user’s last update become more difficult, because the code running on one device doesn’t know what updates have happened on the other device. This metadata will need to be `centralized`.
- If your approach requires reading from the leader, you may first need to `route requests from all of a user’s devices to the same datacenter`.

## Monotonic Reads

When reading from asynchronous followers is that it’s possible for a user to see things `moving backward in time`. This can happen if a user `makes several reads from different replicas`.

`Monotonic reads` is a guarantee that this kind of anomaly does not happen. It’s a lesser guarantee than strong consistency, but `a stronger guarantee than eventual consistency`. When you read data, you may see an old value; monotonic reads only means that if one user makes several reads in sequence, they will not see time go backward—i.e., they will not read older data after having previously read newer data. One way of achieving monotonic reads is to `make sure that each user always makes their reads from the same replica` (different users can read from different replicas). For example, the replica can be chosen based on a hash of the user ID, rather than randomly. However, `if that replica fails, the user’s queries will need to be rerouted to another replica`.

## Consistent Prefix Reads

`consistent prefix reads`: guarantee says that if a sequence of writes happens in a certain order, then anyone reading those writes will see them appear in the same order. If the database always applies writes in the same order, reads always see a consistent prefix, so this anomaly cannot happen.

One solution is to `make sure that any writes that are causally related to each other are written to the same partition`—but in some applications that cannot be done efficiently.

## Solutions for Replication Lag

It is worth thinking about how the application behaves `if the replication lag increases to several minutes or even hours`. If the result is a bad experience for users, it’s important to design the system to provide a stronger guarantee, such as read-after-write.

why `transactions` exist: they are a way for a database to provide stronger guarantees so that the application can be simpler.

# Multi-Leader Replication

`Leader-based replication` has one `major downside`: there is `only one leader`, and all writes must go through it. `If you can’t connect to the leader for any reason, for example due to a network interruption between you and the leader, you can’t write to the database`.

`multi-leader` configuration (also known as `master–master` or `active/active replication`):  `allow more than one node` to accept writes. Replication still happens in the same way: each node that processes a write must forward that data change to all the other nodes.

## Use Cases for Multi-Leader Replication

### Multi-datacenter operation

multi-leader configuration: can have a leader in each datacenter. Within each datacenter, regular leader–follower replication is used; between datacenters, each datacenter’s leader replicates its changes to the leaders in other datacenters.

Compare how the single-leader and multi-leader configurations fare in a multi-datacenter deployment:

- Performance
  - In a single-leader configuration, every write must go over the internet to the datacenter with the leader. This can add `significant latency` to writes and might contravene the purpose of having multiple datacenters in the first place.
  - In a multi-leader configuration, every write can be processed in the local datacenter and is replicated asynchronously to the other datacenters. Thus, the inter-datacenter network delay is hidden from users, which means the perceived performance may be better.
- Tolerance of datacenter outages
  - In a single-leader configuration, if the datacenter with the leader fails, `failover` can promote a follower in another datacenter to be leader.
  - In a multi-leader configuration, each datacenter can `continue operating independently` of the others, and replication catches up when the failed datacenter comes back online.
- Tolerance of network problems
  - Traffic between datacenters usually goes over the public internet, which may be less reliable than the local network within a datacenter.
  - A single-leader configuration is very `sensitive` to problems in this inter-datacenter link, because writes are made synchronously over this link.
  - A multi-leader configuration with `asynchronous` replication can usually `tolerate network problems better`: a temporary network interruption does not prevent writes being processed.

Multi-leader replication `big downside`: the same data may be concurrently modified in two different datacenters, and those write conflicts must be resolved (indicated as `“conflict resolution`).

### Clients with offline operation

Dvery device has a local database that acts as a leader (it accepts write requests), and there is an asynchronous multi-leader replication process (sync) between the replicas of your calendar on all of your devices. The replication lag may be hours or even days, depending on when you have internet access available.

Each device is a “datacenter,” and the network connection between them is extremely unreliable. As the rich history of broken calendar sync implementations demonstrates, multi-leader replication is a tricky thing to get right.

### Collaborative editing

Real-time collaborative editing applications allow several people to edit a document simultaneously. If you want to guarantee that there will be no editing conflicts, the application must obtain a lock on the document before a user can edit it. If another user wants to edit the same document, they first have to wait until the first user has committed their changes and released the lock. This collaboration model is equivalent to single-leader replication with transactions on the leader. However, for faster collaboration, you may want to make the unit of change very small (e.g., a single keystroke) and avoid locking.

## Handling Write Conflicts

### Synchronous vs Asynchronous conflict detection

multi-leader setup, both writes are successful, and the conflict is only detected asynchronously at some later point in time. At that time, it may be too late to ask the user to resolve the conflict.

Make the conflict detection synchronous—i.e., wait for the write to be replicated to all replicas before telling the user that the write was successful.
=> lose the main advantage, might as well just use single-leader replication.

### Conflict avoidance

If the application can ensure that all writes for a particular record go through the same leader, then conflicts cannot occur.

However, sometimes you might want to change the designated leader for a record—perhaps because one datacenter has failed and you need to reroute traffic to another datacenter, or perhaps because a user has moved to a different location and is now closer to a different datacenter. In this situation, conflict avoidance breaks down, and you have to deal with the possibility of concurrent writes on different leaders.

### Converging toward a consistent state

`Convergent` way: all replicas must arrive at the same final value when all changes have been replicated.

Resolution:

- **Give each write a unique ID**, pick the write with the highest ID as the winner, and throw away the other writes. If a timestamp is used, this technique is known as `last write wins (LWW)`.
- **Give each replica a unique ID,** and let writes that originated at a higher-numbered replica always take precedence over writes that originated at a lower-numbered replica.
- **Somehow merge the values together**
- Record the conflict in an explicit data structure that preserves all information, and write application code that resolves the conflict at some later time (perhaps by prompting the user).

### Custom conflict resolution logic

write conflict resolution logic using application code. executed on read or on write:

- `on write`: As soon as the database system detects a conflict in the log of replicated changes, it calls the conflict handler.
- `on read`: When a conflict is detected, all the conflicting writes are stored. The next time the data is read, these multiple versions of the data are returned to the application. The application may prompt the user or automatically resolve the conflict, and write the result back to the database.

Conflict resolution usually `applies at the level of an individual row or document`, not for an entire transaction.

Automatically resolving conflicts algorithm:

- **Conflict-free replicated datatypes (CRDTs)** are a family of data structures for sets, maps (dictionaries), ordered lists, counters, etc. that can be concurrently edited by multiple users, and which automatically resolve conflicts in sensible ways.
- **Mergeable persistent data structures** track history explicitly, similarly to the Git version control system, and use a three-way merge function (whereas CRDTs use two-way merges).
- **Operational transformation**  is the conflict resolution algorithm behind collaborative editing applications. It was designed particularly for concurrent editing of an ordered list of items, such as the list of characters that constitute a text document.

## Multi-Leader Replication Topologies

`replication topology`: describes the communication paths along which writes are propagated from one node to another.

- `all-to-all`: every leader sends its writes to every other leader
- `circular topology`: each node receives writes from one node and forwards those writes (plus any writes of its own) to one other node.
- `star`: one designated root node forwards writes to all of the other nodes. The star topology can be generalized to a tree.

`circular` and `star` might have infinite replication loops. To prevent it, ach node is given a unique identifier, and in the replication log, each write is tagged with the identifiers of all the nodes it has passed through. They might also have problem that,  if just one node fails, it can interrupt the flow of replication messages between other nodes, causing them to be unable to communicate until the node is fixed.

`all-to-all` might have siiue that some network links may be faster than others (e.g., due to network congestion), with the result that some replication messages may “overtake” others.

# Leaderless Replication

In some leaderless implementations, the client directly sends its writes to several replicas. `Coordinator does not enforce a particular ordering of writes`.

## Writing to the Database When a Node is Down

In a leaderless configuration, failover does not exist.

To solve that problem, when a client reads from the database, it doesn’t just send its request to one replica: `read requests are also sent to several nodes in parallel.` The client may get different responses from different nodes; i.e., the up-to-date value from one node and a stale value from another. `Version numbers are used to determine which value is newer`.

### Read repair and anti-entropy

After an unavailable node comes back online, how does it catch up on the writes that it missed?

- Read repair
  - When a client makes a read from several nodes in parallel, it can detect any stale responses. This approach works well for values that are frequently read.
- Anti-entropy process
  - In addition, some datastores have a background process that constantly looks for differences in the data between replicas and copies any missing data from one replica to another. Unlike the replication log in leader-based replication, this anti-entropy process does not copy writes in any particular order, and there may be a significant delay before data is copied.

### Quorums for reading and writing replication

`quorum reads and writes`: if there are n replicas, every write must be confirmed by w nodes to be considered successful, and we must query at least r nodes for each read. As long as w + r > n, we expect to get an up-to-date value when reading, because at least one of the r nodes we’re reading from must be up to date.

In Dynamo-style databases, the parameters n, w, and r are typically configurable. A common choice is to make n an odd number (typically 3 or 5) and to set w = r = (n + 1) / 2 (rounded up).

The quorum condition, w + r > n, allows the system to tolerate unavailable nodes as follows:

- If w < n, we can still process writes if a node is unavailable.
- If r < n, we can still process reads if a node is unavailable.
- With n = 3, w = 2, r = 2 we can tolerate one unavailable node.
- With n = 5, w = 3, r = 3 we can tolerate two unavailable nodes. This case is illustrated in Figure 5-11.
- Normally, reads and writes are always sent to all n replicas in parallel. The parameters w and r determine how many nodes we wait for—i.e., how many of the n nodes need to report success before we consider the read or write to be successful.

## Limitations of Quorum Consistency

However, even with w + r > n, there are likely to be edge cases where stale values are returned.

- If a sloppy quorum is used (see “Sloppy Quorums and Hinted Handoff”), the w writes may end up on different nodes than the r reads, so there is no longer a guaranteed overlap between the r nodes and the w nodes.
- If two writes occur concurrently, it is not clear which one happened first. In this case, the only safe solution is to merge the concurrent writes (see “Handling Write Conflicts”). If a winner is picked based on a timestamp (last write wins), writes can be lost due to clock skew. We will return to this topic in “Detecting Concurrent Writes”.
- If a write happens concurrently with a read, the write may be reflected on only some of the replicas. In this case, it’s undetermined whether the read returns the old or the new value.
- If a write succeeded on some replicas but failed on others (for example because the disks on some nodes are full), and overall succeeded on fewer than w replicas, it is not rolled back on the replicas where it succeeded. This means that if a write was reported as failed, subsequent reads may or may not return the value from that write.
- If a node carrying a new value fails, and its data is restored from a replica carrying an old value, the number of replicas storing the new value may fall below w, breaking the quorum condition.
- Even if everything is working correctly, there are edge cases in which you can get unlucky with the timing, as we shall see in “Linearizability and quorums”.

## Sloppy Quorums and Hinted Handoff

Once the network interruption is fixed, any writes that one node temporarily accepted on behalf of another node are sent to the appropriate “home” nodes. This is called `hinted handoff`.

### Multi-datacenter operation

The number of replicas n includes nodes in all datacenters, and in the configuration you can specify how many of the n replicas you want to have in each datacenter. Each write from a client is sent to all replicas, regardless of datacenter, but the client usually only waits for acknowledgment from a quorum of nodes within its local datacenter so that it is unaffected by delays and interruptions on the cross-datacenter link. The higher-latency writes to other datacenters are often configured to happen asynchronously, although there is some flexibility in the configuration

## Detecting Concurrent Writes

### Last write wins

`last write wins (LWW)`: attach a timestamp to each write, pick the biggest timestamp as the most “recent,” and discard any writes with an earlier timestamp

LWW achieves the goal of eventual convergence, but at the cost of durability: if there are several concurrent writes to the same key, even if they were all reported as successful to the client (because they were written to w replicas), only one of the writes will survive and the others will be silently discarded. Moreover, LWW may even drop writes that are not concurrent.

The only safe way of using a database with LWW is to `ensure that a key is only written once and thereafter treated as immutable`, thus avoiding any concurrent updates to the same key.

### "happens-before" relationship and concurrency

An operation A `happens before` another operation B if B knows about A, or depends on A, or builds upon A in some way. Whether one operation happens before another operation is the key to defining what concurrency means. In fact, we can simply say that two operations are concurrent if neither happens before the other (i.e., neither knows about the other).

For defining `concurrency`, exact time doesn’t matter: we simply call two operations concurrent `if they are both unaware of each other, regardless of the physical time at which they occurred`.

### Capturing the happens-before relationship

- The server maintains a version number for every key, increments the version number every time that key is written, and stores the new version number along with the value written.
- When a client reads a key, the server returns all values that have not been overwritten, as well as the latest version number. A client must read a key before writing.
- When a client writes a key, it must include the version number from the prior read, and it must merge together all values that it received in the prior read. (The response from a write request can be like a read, returning all current values, which allows us to chain several writes like in the shopping cart example.)
- When the server receives a write with a particular version number, it can overwrite all values with that version number or below (since it knows that they have been merged into the new value), but it must keep all values with a higher version number (because those values are concurrent with the incoming write).

### Merging concurrently written values

`siblings`: if several operations happen concurrently, clients have to clean up afterward by merging the concurrently written values.

`tombstone`: an item cannot simply be deleted from the database when it is removed; instead, the system must leave a marker with an appropriate version number to indicate that the item has been removed when merging siblings

# Summary

Replication can serve several purposes:

- High availability
  - Keeping the system running, even when one machine (or several machines, or an entire datacenter) goes down
- Disconnected operation
  - Allowing an application to continue working when there is a network interruption
- Latency
  - Placing data geographically close to users, so that users can interact with it faster
- Scalability
  - Being able to handle a higher volume of reads than a single machine could handle, by performing reads on replicas

Replication Approaches:

- Single-leader replication
  - Clients send all writes to a single node (the leader), which sends a stream of data change events to the other replicas (followers). Reads can be performed on any replica, but reads from followers might be stale.
  - fairly easy to understand and there is no conflict resolution to worry about
- Multi-leader replication
  - Clients send each write to one of several leader nodes, any of which can accept writes. The leaders send streams of data change events to each other and to any follower nodes.
  - more robust in the presence of faulty nodes, network interruptions, and latency spikes—at the cost of being harder to reason about and providing only very weak consistency guarantees.
- Leaderless replication
  - Clients send each write to several nodes, and read from several nodes in parallel in order to detect and correct nodes with stale data.

a few consistency models which are helpful for deciding how an application should behave under replication lag:

- Read-after-write consistency
  - Users should always see data that they submitted themselves.
- Monotonic reads
  - After users have seen the data at one point in time, they shouldn’t later see the data from some earlier point in time.
- Consistent prefix reads
  - Users should see the data in a state that makes causal sense: for example, seeing a question and its reply in the correct order.

#### Reference

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch05.html>
