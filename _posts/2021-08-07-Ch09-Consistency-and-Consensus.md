---
layout: post
title: Ch09 Consistency and Consensus
date: 2021-08-07 18:13:00
comment_id: 185
categories: [Data Systems, System Design]
tags: [Designing Data Intensive Applications]
---

`tolerating faults`: keeping the service functioning correctly, even if some internal component is faulty.

`eventual consistency/convergence`: if you stop writing to the database and wait for some unspecified length of time, then eventually all read requests will return the same value. n other words, the inconsistency is temporary, and it eventually resolves itself (assuming that any faults in the network are also eventually repaired).

# Linearizability

`linearizability/consistency/strong consistency/immediate consistency/external consistency`: the basic idea is to make a system appear as if there were only one copy of the data, and all operations on it are atomic.

`Linearizability` is a `recency guarantee`.

Once a new value has been written or read, all subsequent reads see the value that was written, until it is overwritten again. It is possible (though computationally expensive) to test whether a system’s behavior is linearizable by recording the timings of all requests and responses, and checking whether they can be arranged into a valid sequential order.

**Linearizability vs Serializability**

- Serializability
  - Serializability is an `isolation property of transactions`, where every transaction may read and write multiple objects (rows, documents, records). It guarantees that transactions behave the same as if they had executed in some serial order (each transaction running to completion before the next transaction starts). It is okay for that serial order to be different from the order in which transactions were actually run.
- Linearizability
  - Linearizability is a `recency guarantee on reads and writes of a register (an individual object)`. It doesn’t group operations together into transactions, so it does not prevent problems such as write skew, unless you take additional measures such as materializing conflicts.

A database may provide both serializability and linearizability, and this combination is known as `strict serializability` or `strong one-copy serializability (strong-1SR)`. Implementations of serializability based on two-phase locking or actual serial execution are typically linearizable.

However, serializable snapshot isolation(SSI) is not linearizable.

## Relying on Linearizability

- Locking and leader election
  - A system that uses single-leader replication needs to ensure that there is indeed only one leader, not several (split brain). One way of electing a leader is to use a lock. No matter how this lock is implemented, it must be linearizable: all nodes must agree which node owns the lock; otherwise it is useless.
- Constraints and uniqueness guarantees
  - ex: if you want to ensure that a bank account balance never goes negative, or that you don’t sell more items than you have in stock in the warehouse, or that two people don’t concurrently book the same seat on a flight or in a theater. These constraints all require there to be a single up-to-date value (the account balance, the stock level, the seat occupancy) that all nodes agree on.
- Cross-channel timing dependencies
  - ex: say you have a website where users can upload a photo, and a background process resizes the photos to lower resolution for faster download (thumbnails). The image resizer needs to be explicitly instructed to perform a resizing job, and this instruction is sent from the web server to the resizer via a message queue, The web server doesn’t place the entire photo on the queue, since most message brokers are designed for small messages, and a photo may be several megabytes in size. Instead, the photo is first written to a file storage service, and once the write is complete, the instruction to the resizer is placed on the queue.

## Implementing Linearizable Systems

- Single-leader replication (potentially linearizable)
  - the leader has the primary copy of the data that is used for writes, and the followers maintain backup copies of the data on other nodes. If you make reads from the leader, or from synchronously updated followers, they have the `potential to be linearizable`
  - Using the leader for reads relies on the assumption that you know for sure who the leader is.
- Consensus algorithms (linearizable)
  - consensus protocols contain measures to prevent split brain and stale replicas. Thanks to these details, consensus algorithms can implement linearizable storage safely.
- Multi-leader replication (not linearizable)
  - not linearizable, because they concurrently process writes on multiple nodes and asynchronously replicate them to other nodes.
- Leaderless replication (probably not linearizable)
  - obtain “strong consistency” by requiring quorum reads and writes (w + r > n). Depending on the exact configuration of the quorums, and depending on how you define strong consistency, this is `not quite true`.

## The Cost of Linearizability

If there is a network interruption between the two datacenters. Let’s assume that the network within each datacenter is working, and clients can reach the datacenters, but the datacenters cannot connect to each other. If clients can connect directly to the leader datacenter, this is not a problem, since the application continues to work normally there. But clients that can only reach a follower datacenter will experience an outage until the network link is repaired.

**CAP(Consistency, Availability, Partition)**

- pick 2 out of 3
- At times when the network is working correctly, a system can provide both consistency (linearizability) and total availability. When a network fault occurs, you have to choose between either linearizability or total availability. Thus, a better way of phrasing CAP would be either Consistent or Available when Partitioned
- The CAP theorem as formally defined is of very narrow scope. It doesn’t say anything about network delays, dead nodes, or other trade-offs. Thus, although `CAP has been historically influential`, it has little practical value for designing systems.

`Few systems are actually linearizable`. Why make this trade-off? Within one computer we usually assume reliable communication, and we don’t expect one CPU core to be able to continue operating normally if it is disconnected from the rest of the computer. The reason for dropping linearizability is `performance`, not fault tolerance.

# Ordering Guarantees

## Ordering and Causality

Why `ordering` keeps coming up, and one of the reasons is that `it helps preserve causality`.

`causally consistent`: a system obeys the ordering imposed by causality

### The causal order is not a total order

A `total order` allows any two elements to be compared.

The difference between a total order and a partial order is reflected in different database consistency models:

- Linearizability
  - In a linearizable system, we have a total order of operations: if the system behaves as if there is only a single copy of the data, and every operation is atomic, this means that for any two operations we can always say which one happened first.
- Causality
  - We said that two operations are concurrent if neither happened before the other (see “The “happens-before” relationship and concurrency”). This means that `causality defines a partial order`, not a total order: some operations are ordered with respect to each other, but some are incomparable.

### Linearizability is stronger than causal consistency

Linearizability implies causality: any system that is linearizable will preserve causality correctly.

Linearizability is not the only way of preserving causality—there are other ways too. A system can be causally consistent without incurring the performance hit of making it linearizable (in particular, the CAP theorem does not apply).

### Capturing causal dependencies

Concurrent operations may be processed in any order, but if one operation happened before another, then they must be processed in that order on every replica.

Causal consistency goes further: it needs to track causal dependencies across the entire database, not just for a single key. Version vectors can be generalized to do this. In order to determine the causal ordering, the database needs to know which version of the data was read by the application.

## Sequence Number Ordering

Use `sequence numbers` or `timestamps` to order events. A timestamp come from a `logical clock`, which is an algorithm to generate a sequence of numbers to identify operations, typically using counters that are incremented for every operation.

Such sequence numbers or timestamps are compact (only a few bytes in size), and they provide a total order: that is, every operation has a unique sequence number, and you can always compare two sequence numbers to determine which is greater (i.e., which operation happened later).

`consistent with causality`: we promise that if operation A causally happened before B, then A occurs before B in the total order (A has a lower sequence number than B). Concurrent operations may be ordered arbitrarily. Such a total order captures all the causality information, but also imposes more ordering than strictly required by causality.

### Lamport timestamps

`Lamport timestamps`: Each node has a unique identifier, and each node keeps a counter of the number of operations it has processed. The Lamport timestamp is then simply a pair of (counter, node ID). Two nodes may sometimes have the same counter value, but by including the node ID in the timestamp, each timestamp is made unique.

It `provides total ordering`: if you have two timestamps, the one with a greater counter value is the greater timestamp; if the counter values are the same, the one with the greater node ID is the greater timestamp.

Every node and every client keeps track of the maximum counter value it has seen so far, and includes that maximum on every request. When a node receives a request or response with a maximum counter value greater than its own counter value, it immediately increases its own counter to that maximum.

**Lamport timestamps vs Version vectors**

They have a different purpose: `version vectors` can distinguish whether two operations are concurrent or whether one is causally dependent on the other, whereas `Lamport timestamps` always enforce a total ordering. From the total ordering of Lamport timestamps, you cannot tell whether two operations are concurrent or whether they are causally dependent. The advantage of Lamport timestamps over version vectors is that they are more compact.

## Total Order Broadcast

`total order broadcast/atomic broadcast`: The challenge then is how to scale the system if the throughput is greater than a single leader can handle, and also how to handle failover if the leader fails.

Total order broadcast is usually described as a protocol for exchanging messages between nodes. Informally, it requires that two safety properties always be satisfied:

- Reliable delivery
  - No messages are lost: if a message is delivered to one node, it is delivered to all nodes.
- Totally ordered delivery
  - Messages are delivered to every node in the same order.

### Using total order broadcast

- for database replication
  - `state machine replication`: if every message represents a write to the database, and every replica processes the same writes in the same order, then the replicas will remain consistent with each other (aside from any temporary replication lag).
- used to implement serializable transactions
  - if every message represents a deterministic transaction to be executed as a stored procedure, and if every node processes those messages in the same order, then the partitions and replicas of the database are kept consistent with each other
- way of creating a log (as in a replication log, transaction log, or write-ahead log)
  - delivering a message is like appending to the log. Since all nodes must deliver the same messages in the same order, all nodes can read the log and see the same sequence of messages.
- for implementing a lock service that provides fencing tokens
  - Every request to acquire the lock is appended as a message to the log, and all messages are sequentially numbered in the order they appear in the log. The sequence number can then serve as a fencing token, because it is `monotonically increasing`.

### Implementing linearizable storage using total order broadcast

Total order broadcast is asynchronous. linearizability is a recency guarantee.

If you have total order broadcast, you can build linearizable storage on top of it. Implement such a linearizable compare-and-set operation as follows by using total order broadcast as an append-only log:

- Append a message to the log, tentatively indicating the username you want to claim.
- Read the log, and wait for the message you appended to be delivered back to you.
- Check for any messages claiming the username that you want. If the first message for your desired username is your own message, then you are successful: you can commit the username claim (perhaps by appending another message to the log) and acknowledge it to the client. If the first message for your desired username is from another user, you abort the operation.

While this procedure ensures linearizable writes, it doesn’t guarantee linearizable reads—if you read from a store that is asynchronously updated from the log, it may be stale.(the procedure described here provides sequential consistency, sometimes also known as timeline consistency, a slightly weaker guarantee than linearizability.) To make reads linearizable, there are a few options:

- sequence reads through the log by appending a message, reading the log, and performing the actual read when the message is delivered back to you. The message’s position in the log thus defines the point in time at which the read happens.
- If the log allows you to fetch the position of the latest log message in a linearizable way, you can query that position, wait for all entries up to that position to be delivered to you, and then perform the read.
- You can make your read from a replica that is synchronously updated on writes, and is thus sure to be up to date.

### Implementing total order broadcast using linearizable storage

For every message you want to send through total order broadcast, you increment-and-get the linearizable integer, and then attach the value you got from the register as a sequence number to the message. You can then send the message to all nodes (resending any lost messages), and the recipients will deliver the messages consecutively by sequence number.

# Distributed Transactions and Consensus

`FLP result`: there is no algorithm that is always able to reach consensus if there is a risk that a node may crash.

If the algorithm is allowed to use timeouts, or some other way of identifying suspected crashed nodes (even if the suspicion is sometimes wrong), then consensus becomes solvable. Thus, although the FLP result about the impossibility of consensus is of great theoretical importance, distributed systems can usually achieve consensus in practice.

## Atomic Commit and Two-Phase Commit (2PC)

### From single-node to distributed atomic commit

On a single node, transaction commitment crucially depends on the order in which data is durably written to disk: first the data, then the commit record. A transaction commit must be `irrevocable`—you are not allowed to change your mind and retroactively abort a transaction after it has been committed.

### Introduction to two-phase commit

`Two-phase commit` is an algorithm for achieving atomic transaction commit across multiple nodes—i.e., to ensure that either all nodes commit or all nodes abort.

2PC uses a new component that does not normally appear in single-node transactions: a coordinator (also known as transaction manager). The coordinator is often implemented as a library within the same application process that is requesting the transaction. A 2PC transaction begins with the application reading and writing data on multiple database nodes, as normal. We call these database nodes participants in the transaction. When the application is ready to commit, the coordinator begins phase 1: it sends a prepare request to each of the nodes, asking them whether they are able to commit. The coordinator then tracks the responses from the participants:

- If all participants reply “yes,” indicating they are ready to commit, then the coordinator sends out a commit request in phase 2, and the commit actually takes place.
- If any of the participants replies “no,” the coordinator sends an abort request to all nodes in phase 2.

### A system of promises

- When the application wants to begin a distributed transaction, it requests a transaction ID from the coordinator. `This transaction ID is globally unique`.
- The application begins a single-node transaction on each of the participants, and attaches the globally unique transaction ID to the single-node transaction. All reads and writes are done in one of these single-node transactions. `If anything goes wrong at this stage, the coordinator or any of the participants can abort`.
- When the application is ready to commit, the coordinator sends a prepare request to all participants, tagged with the global transaction ID. If any of these requests fails or times out, the coordinator sends an abort request for that transaction ID to all participants.
- When a participant receives the prepare request, it makes sure that it can definitely commit the transaction under all circumstances. This includes writing all transaction data to disk (a crash, a power failure, or running out of disk space is not an acceptable excuse for refusing to commit later), and checking for any conflicts or constraint violations. By replying “yes” to the coordinator, the node promises to commit the transaction without error if requested. In other words, the participant surrenders the right to abort the transaction, but without actually committing it.
- When the coordinator has received responses to all prepare requests, it makes a definitive decision on whether to commit or abort the transaction (committing only if all participants voted “yes”). The coordinator must write that decision to its transaction log on disk so that it knows which way it decided in case it subsequently crashes. This is called the commit point.
- Once the coordinator’s decision has been written to disk, the commit or abort request is sent to all participants. If this request fails or times out, the coordinator must retry forever until it succeeds. There is no more going back: if the decision was to commit, that decision must be enforced, no matter how many retries it takes. If a participant has crashed in the meantime, the transaction will be committed when it recovers—since the participant voted “yes,” it cannot refuse to commit when it recovers.

The protocol contains two crucial “points of no return”:

- when a participant votes “yes,” it promises that it will definitely be able to commit later (although the coordinator may still choose to abort);
- and once the coordinator decides, that decision is irrevocable.

### Coordinator failure

If the coordinator fails before sending the prepare requests, a participant can safely abort the transaction. But once the participant has received a prepare request and voted “yes,” it can no longer abort unilaterally—it must wait to hear back from the coordinator whether the transaction was committed or aborted. If the coordinator crashes or the network fails at this point, the participant can do nothing but wait. A participant’s transaction in this state is called `in doubt` or `uncertain`.

This is why the coordinator `must write its commit or abort decision to a transaction log` on disk before sending commit or abort requests to participants: when the coordinator recovers, it determines the status of all in-doubt transactions by reading its transaction log. Any transactions that don’t have a commit record in the coordinator’s log are aborted.

### Three-phase commit

Two-phase commit is called a `blocking atomic commit` protocol due to the fact that 2PC can become stuck waiting for the coordinator to recover.

`three-phase commit (3PC)`: 3PC assumes a network with bounded delay and nodes with bounded response times; in most practical systems with unbounded network delay and process pauses it cannot guarantee atomicity.

In general, nonblocking atomic commit requires a `perfect failure detector`—i.e., a reliable mechanism for telling whether a node has crashed or not.

## Distributed T

Two quite different types of distributed transactions are often conflated:

- Database-internal distributed transactions
  - Some distributed databases (i.e., databases that use replication and partitioning in their standard configuration) support internal transactions among the nodes of that database. For example, VoltDB and MySQL Cluster’s NDB storage engine have such internal transaction support. In this case, all the nodes participating in the transaction are running the same database software.
- Heterogeneous distributed transactions
  - In a heterogeneous transaction, the participants are two or more different technologies: for example, two databases from different vendors, or even non-database systems such as message brokers. A distributed transaction across these systems must ensure atomic commit, even though the systems may be entirely different under the hood.

### XA transactions

X/Open XA (short for eXtended Architecture) is a standard for implementing two-phase commit across heterogeneous technologies.

XA is not a network protocol—it is merely a C API for interfacing with a transaction coordinator. XA assumes that your application uses a network driver or client library to communicate with the participant databases or messaging services. If the driver supports XA, that means it calls the XA API to find out whether an operation should be part of a distributed transaction—and if so, it sends the necessary information to the database server. The driver also exposes callbacks through which the coordinator can ask the participant to prepare, commit, or abort. It keeps track of the participants in a transaction, collects partipants’ responses after asking them to prepare (via a callback into the driver), and uses a log on the local disk to keep track of the commit/abort decision for each transaction.

If the application process crashes, or the machine on which the application is running dies, the coordinator goes with it. Any participants with prepared but uncommitted transactions are then stuck in doubt. Since the coordinator’s log is on the application server’s local disk, that server must be restarted, and the coordinator library must read the log to recover the commit/abort outcome of each transaction. Only then can the coordinator use the database driver’s XA callbacks to ask participants to commit or abort, as appropriate. The database server cannot contact the coordinator directly, since all communication must go via its client library.

### Recovering from coordinator failure

`orphaned in-doubt` transactions: transactions for which the coordinator cannot decide the outcome for whatever reason (e.g., because the transaction log has been lost or corrupted due to a software bug). These transactions cannot be resolved automatically, so they sit forever in the database, holding locks and blocking other transactions.

The only way out is for an administrator to manually decide whether to commit or roll back the transactions.

Many XA implementations have an emergency escape hatch called `heuristic decisions`: allowing a participant to unilaterally decide to abort or commit an in-doubt transaction without a definitive decision from the coordinator. Heuristic here is a euphemism for `probably breaking atomicity`, since the heuristic decision violates the system of promises in two-phase commit. Thus, heuristic decisions are intended only for getting out of catastrophic situations, and not for regular use.

### Limitations of distributed transactions

- If the coordinator is not replicated but runs only on a single machine, it is a single point of failure for the entire system (since its failure causes other application servers to block on locks held by in-doubt transactions). Surprisingly, many coordinator implementations are not highly available by default, or have only rudimentary replication support.
- Many server-side applications are developed in a stateless model (as favored by HTTP), with all persistent state stored in a database, which has the advantage that application servers can be added and removed at will. However, when the coordinator is part of the application server, it changes the nature of the deployment. Suddenly, the coordinator’s logs become a crucial part of the durable system state—as important as the databases themselves, since the coordinator logs are required in order to recover in-doubt transactions after a crash. Such application servers are no longer stateless.
- Since XA needs to be compatible with a wide range of data systems, it is necessarily a lowest common denominator. For example, it cannot detect deadlocks across different systems (since that would require a standardized protocol for systems to exchange information on the locks that each transaction is waiting for), and it does not work with SSI (see “Serializable Snapshot Isolation (SSI)”), since that would require a protocol for identifying conflicts across different systems.
- For database-internal distributed transactions (not XA), the limitations are not so great—for example, a distributed version of SSI is possible. However, there remains the problem that for 2PC to successfully commit a transaction, all participants must respond. Consequently, if any part of the system is broken, the transaction also fails. Distributed transactions thus have a tendency of amplifying failures, which runs counter to our goal of building fault-tolerant systems.

## Fault-Tolerant Consensus

The `consensus` problem is normally formalized as follows: one or more nodes may propose values, and the consensus algorithm decides on one of those values. A consensus algorithm must satisfy the following properties:

- Uniform agreement
  - No two nodes decide differently.
- Integrity
  - No node decides twice.
- Validity
  - If a node decides value v, then v was proposed by some node.
- Termination
  - Every node that does not crash eventually decides some value.

### Consensus algorithms and total order broadcast

Total order broadcast is equivalent to repeated rounds of consensus (each consensus decision corresponding to one message delivery):

- Due to the agreement property of consensus, all nodes decide to deliver the same messages in the same order.
- Due to the integrity property, messages are not duplicated.
- Due to the validity property, messages are not corrupted and not fabricated out of thin air.
- Due to the termination property, messages are not lost.

### Epoch numbering and quorums

The protocols define an `epoch number`. Guarantee that within each epoch, the leader is unique.

Every time the current leader is thought to be dead, a vote is started among the nodes to elect a new leader. This election is given an incremented epoch number, and thus epoch numbers are totally ordered and monotonically increasing. If there is a conflict between two different leaders in two different epochs (perhaps because the previous leader actually wasn’t dead after all), then the leader with the higher epoch number prevails.

For every decision that a leader wants to make, it must send the proposed value to the other nodes and wait for a `quorum` of nodes to respond in favor of the proposal.

Two rounds of voting: once to choose a leader, and a second time to vote on a leader’s proposal.

### Limitations of consensus

- Consensus systems always require a strict majority to operate.
- Consensus systems generally rely on timeouts to detect failed nodes.
- consensus algorithms are particularly sensitive to network problems.

## Membership and Coordination Services

- Linearizable atomic operations
  - Using an atomic compare-and-set operation, you can implement a lock: if several nodes concurrently try to perform the same operation, only one of them will succeed. The consensus protocol guarantees that the operation will be atomic and linearizable, even if a node fails or the network is interrupted at any point. A distributed lock is usually implemented as a lease, which has an expiry time so that it is eventually released in case the client fails
- Total ordering of operations
  - when some resource is protected by a lock or lease, you need a fencing token to prevent clients from conflicting with each other in the case of a process pause. The fencing token is some number that monotonically increases every time the lock is acquired.
- Failure detection
  - Clients maintain a long-lived session on ZooKeeper servers, and the client and server periodically exchange heartbeats to check that the other node is still alive. Even if the connection is temporarily interrupted, or a ZooKeeper node fails, the session remains active. However, if the heartbeats cease for a duration that is longer than the session timeout, ZooKeeper declares the session to be dead. Any locks held by a session can be configured to be automatically released when the session times out (ZooKeeper calls these ephemeral nodes).
- Change notifications
  - Not only can one client read locks and values that were created by another client, but it can also watch them for changes. Thus, a client can find out when another client joins the cluster, or if another client fails (because its session times out and its ephemeral nodes disappear). By subscribing to notifications, a client avoids having to frequently poll to find out about changes.

### Allocating work to nodes

- if you have several instances of a process or service, and one of them needs to be chosen as leader or primary. If the leader fails, one of the other nodes should take over
- when you have some partitioned resource (database, message streams, file storage, distributed actor system, etc.) and need to decide which partition to assign to which node. As new nodes join the cluster, some of the partitions need to be moved from existing nodes to the new nodes in order to rebalance the load. As nodes are removed or fail, other nodes need to take over the failed nodes’ work.

### Service discovery

`service discovery`: to find out which IP address you need to connect to in order to reach a particular service.

Although service discovery does not require consensus, leader election does. Thus, if your consensus system already knows who the leader is, then it can make sense to also use that information to help other services discover who the leader is.

### Membership services

A `membership service` determines which nodes are currently active and live members of a cluster.

# Summary

A wide range of problems are actually reducible to consensus and are equivalent to each other:

- Linearizable compare-and-set registers
  - The register needs to atomically decide whether to set its value, based on whether its current value equals the parameter given in the operation.
- Atomic transaction commit
  - A database must decide whether to commit or abort a distributed transaction.
- Total order broadcast
  - The messaging system must decide on the order in which to deliver messages.
- Locks and leases
  - When several clients are racing to grab a lock or lease, the lock decides which one successfully acquired it.
- Membership/coordination service
  - Given a failure detector (e.g., timeouts), the system must decide which nodes are alive, and which should be considered dead because their sessions timed out.
- Uniqueness constraint
  - When several transactions concurrently try to create conflicting records with the same key, the constraint must decide which one to allow and which should fail with a constraint violation.

If that single leader fails, or if a network interruption makes the leader unreachable, such a system becomes unable to make any progress. There are three ways of handling that situation:

- Wait for the leader to recover, and accept that the system will be blocked in the meantime. Many XA/JTA transaction coordinators choose this option. This approach does not fully solve consensus because it does not satisfy the termination property: if the leader does not recover, the system can be blocked forever.
- Manually fail over by getting humans to choose a new leader node and reconfigure the system to use it. Many relational databases take this approach. It is a kind of consensus by “act of God”—the human operator, outside of the computer system, makes the decision. The speed of failover is limited by the speed at which humans can act, which is generally slower than computers.
- Use an algorithm to automatically choose a new leader. This approach requires a consensus algorithm, and it is advisable to use a proven algorithm that correctly handles adverse network conditions

#### Reference

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch09.html>
