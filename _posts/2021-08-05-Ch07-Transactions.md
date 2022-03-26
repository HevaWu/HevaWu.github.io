---
layout: post
title: Ch07 Transactions
date: 2021-08-05 18:52:00
comment_id: 184
categories: [Data Systems, System Design]
tags: [Designing Data Intensive Applications]
---

`transaction`: a way for an application to group several reads and writes together into a logical unit. Conceptually, `all the reads and writes in a transaction are executed as one operation`: either the entire transaction succeeds (commit) or it fails (abort, rollback). If it fails, the application can safely retry. With transactions, error handling becomes much simpler for an application, because it doesn’t need to worry about partial failure—i.e., the case where some operations succeed and some fail (for whatever reason).

`safety guarantees`: By using transactions, the application is free to ignore certain potential error scenarios and concurrency issues, because the database takes care of them instead.

# The Slippery Concept of a Transaction

## Meaning of ACID

- `ACID`: Atomicity, Consistency, Isolation, and Durability
- `BASE`: Basically Available, Soft state, and Eventual consistency

ACID:

- `atomicity`
  - describes what happens if a client wants to make several writes, but a fault occurs after some of the writes have been processed. If a transaction was aborted, the application can be sure that it didn’t change anything, so it can safely be retried.
  - If an error occurs halfway through a sequence of writes, the transaction should be aborted, and the writes made up to that point should be discarded. In other words, the database saves you from having to worry about partial failure, by giving an all-or-nothing guarantee.
- `consistency`
  - refers to an application-specific notion of the database being in a “good state.” Atomicity, isolation, and durability are properties of the database, whereas consistency (in the ACID sense) is a property of the application.
- `isolation`
  - in the sense of ACID means that concurrently executing transactions are isolated from each other.
  - Concurrently running transactions shouldn’t interfere with each other. For example, if one transaction makes several writes, then another transaction should see either all or none of those writes, but not some subset.
- `durability`:
  - once a transaction has committed successfully, any data it has written will not be forgotten, even if there is a hardware fault or the database crashes.

## Single-Object and Multi-Object Operations

### Single-Object writes

Atomicity can be implemented using a log for crash recovery, and isolation can be implemented using a lock on each object (allowing only one thread to access an object at any one time).

Some databases also provide more complex atomic operations, such as an `increment operation`, which removes the need for a read-modify-write cycle. Similarly popular is a `compare-and-set operation`, which allows a write to happen only if the value has not been concurrently changed by someone else.

# Weak Isolation Levels

## Read Committed

two guarantees:

- When reading from the database, you will only see data that has been committed (`no dirty reads`).
- When writing to the database, you will only overwrite data that has been committed (`no dirty writes`).

How to prevent dirty write?

- `using row-level locks`: when a transaction wants to modify a particular object (row or document), it must first acquire a lock on that object. It must then hold that lock until the transaction is committed or aborted. Only one transaction can hold the lock for any given object; if another transaction wants to write to the same object, it must wait until the first transaction is committed or aborted before it can acquire the lock and continue. This locking is done automatically by databases in read committed mode (or stronger isolation levels).

How to prevent dirty read?

- `use the same lock`, and to require any transaction that wants to read an object to briefly acquire the lock and then release it again immediately after reading. This would ensure that a read couldn’t happen while an object has a dirty, uncommitted value (because during that time the lock would be held by the transaction that has made the write).
- for every object that is written, the `database remembers both the old committed value and the new value` set by the transaction that currently holds the write lock. While the transaction is ongoing, any other transactions that read the object are simply given the old value. Only when the new value is committed do transactions switch over to reading the new value.

## Snapshot Isolation and Repeatable Read

- `read skew`:
  - example: Say Alice has $1,000 of savings at a bank, split across two accounts with $500 each. Now a transaction transfers $100 from one of her accounts to the other. If she is unlucky enough to look at her list of account balances in the same moment as that transaction is being processed, she may see one account balance at a time before the incoming payment has arrived (with a balance of $500), and the other account after the outgoing transfer has been made (the new balance being $400). To Alice it now appears as though she only has a total of $900 in her accounts—it seems that $100 has vanished into thin air.

some situations cannot tolerate such temporary inconsistency:

- Backups
  - Taking a backup requires making a copy of the entire database, which may take hours on a large database. During the time that the backup process is running, writes will continue to be made to the database. Thus, you could end up with some parts of the backup containing an older version of the data, and other parts containing a newer version. If you need to restore from such a backup, the inconsistencies (such as disappearing money) become permanent.
- Analytic queries and integrity checks
  - Sometimes, you may want to run a query that scans over large parts of the database. Such queries are common in analytics (see “Transaction Processing or Analytics?”), or may be part of a periodic integrity check that everything is in order (monitoring for data corruption). These queries are likely to return nonsensical results if they observe parts of the database at different points in time.

`Snapshot isolation`: `each transaction reads from a consistent snapshot of the database`—that is, the transaction sees all the data that was committed in the database at the start of the transaction. Even if the data is subsequently changed by another transaction, each transaction sees only the old data from that particular point in time.

### Implement snapshot isolation

Use write locks to prevent dirty writes. However, reads do not require any locks.

A key principle of snapshot isolation is readers never block writers, and writers never block readers.

`multi-version concurrency control (MVCC)`: The database must potentially keep several different committed versions of an object, because various in-progress transactions may need to see the state of the database at different points in time.

### Visibility rules for observing a consistent snapshot

rules:

- At the start of each transaction, the database makes a list of all the other transactions that are in progress (not yet committed or aborted) at that time. Any writes that those transactions have made are ignored, even if the transactions subsequently commit.
- Any writes made by aborted transactions are ignored.
- Any writes made by transactions with a later transaction ID (i.e., which started after the current transaction started) are ignored, regardless of whether those transactions have committed.
- All other writes are visible to the application’s queries.

an object is visible if both of the following conditions are true:

- At the time when the reader’s transaction started, the transaction that created the object had already committed.
- The object is not marked for deletion, or if it is, the transaction that requested deletion had not yet committed at the time when the reader’s transaction started.

### How do indexes work in a multi-version database?

- One option is to `have the index simply point to all versions of an object` and require an index query to filter out any object versions that are not visible to the current transaction. When garbage collection removes old object versions that are no longer visible to any transaction, the corresponding index entries can also be removed.
- use an `append-only/copy-on-write variant` that does not overwrite pages of the tree when they are updated, but instead creates a new copy of each modified page. Parent pages, up to the root of the tree, are copied and updated to point to the new versions of their child pages. Any pages that are not affected by a write do not need to be copied, and remain immutable. With append-only B-trees, every write transaction (or batch of transactions) creates a new B-tree root, and a particular root is a consistent snapshot of the database at the point in time when it was created. There is no need to filter out objects based on transaction IDs because subsequent writes cannot modify an existing B-tree; they can only create new tree roots. However, this approach also `requires a background process for compaction and garbage collection`.

## Preventing Lost Update

`lost update` problem: can occur if an application reads some value from the database, modifies it, and writes back the modified value (a read-modify-write cycle). If two transactions do this concurrently, one of the modifications can be lost, because the second write does not include the first modification.

### Atomic write operations

`atomic update operations`: which remove the need to implement read-modify-write cycles in application code. Not all writes can easily be expressed in terms of atomic operations, but in situations where atomic operations can be used, they are usually the best choice.

`cursor stability`: Atomic operations are usually implemented by taking an exclusive lock on the object when it is read so that no other transaction can read it until the update has been applied.

Another option is to simply force all atomic operations to be executed on a single thread.

### Explicit locking

If the database’s built-in atomic operations don’t provide the necessary functionality, for the application to explicitly lock objects that are going to be updated. Then the application can perform a read-modify-write cycle, and if any other transaction tries to concurrently read the same object, it is forced to wait until the first read-modify-write cycle has completed.

### Automatically detecting lost updates

An alternative is to allow them to execute in parallel and, if the transaction manager detects a lost update, abort the transaction and force it to retry its read-modify-write cycle.

An `advantage` of this approach is that databases can perform this check efficiently in conjunction with snapshot isolation.

### Compare-and-set

`compare-and-set operation`: The purpose of this operation is to avoid lost updates by allowing an update to happen only if the value has not changed since you last read it. If the current value does not match what you previously read, the update has no effect, and the read-modify-write cycle must be retried.

### Conflict resolution and replication

`databases with multi-leader or leaderless replication`, a common approach in such replicated databases is to allow concurrent writes to create several conflicting versions of a value (also known as siblings), and to use application code or special data structures to resolve and merge these versions after the fact.

## Write Skew and Phantoms

`write skew`: Write skew can occur if two transactions read the same objects, and then update some of those objects.

write skew pattern:

A SELECT query checks whether some requirement is satisfied by searching for rows that match some search condition (there are at least two doctors on call, there are no existing bookings for that room at that time, the position on the board doesn’t already have another figure on it, the username isn’t already taken, there is still money in the account).

1. Depending on the result of the first query, the application code decides how to continue .
2. If the application decides to go ahead, it makes a write (INSERT, UPDATE, or DELETE) to the database and commits the transaction
3. The effect of this write changes the precondition of the decision of step 2. In other words, if you were to repeat the SELECT query from step 1 after committing the write, you would get a different result, because the write changed the set of rows matching the search condition.

`phantom`: a write in one transaction changes the result of a search query in another transaction.

Snapshot isolation avoids phantoms in read-only queries, but in read-write transactions, phantoms can lead to particularly tricky cases of write skew.

`materializing conflicts`, takes a phantom and turns it into a lock conflict on a concrete set of rows that exist in the database.

# Serializability

`serializable isolation`: guarantees that even though transactions may execute in parallel, the end result is the same as if they had executed one at a time, serially, without any concurrency.

Most databases that provide serializability today use one of three techniques:

- Literally executing transactions in a serial order
- Two-phase locking
- Optimistic concurrency control techniques such as serializable snapshot isolation

## Actual Serial Execution

`stored procedure`: all data required by a transaction is in memory, the stored procedure can execute very fast, without waiting for any network or disk I/O.

- Every transaction must be small and fast, because it takes only one slow transaction to stall all transaction processing.
- It is limited to use cases where the active dataset can fit in memory. Rarely accessed data could potentially be moved to disk, but if it needed to be accessed in a single-threaded transaction, the system would get very slow.x
- Write throughput must be low enough to be handled on a single CPU core, or else transactions need to be partitioned without requiring cross-partition coordination.
- Cross-partition transactions are possible, but there is a hard limit to the extent to which they can be used.

## Two-Phase Locking(2PL)

`Two-phase locking`: Several transactions are allowed to concurrently read the same object as long as nobody is writing to it. But as soon as anyone wants to write (modify or delete) an object, exclusive access is required:

- If transaction A has read an object and transaction B wants to write to that object, B must wait until A commits or aborts before it can continue. (This ensures that B can’t change the object unexpectedly behind A’s back.)
- If transaction A has written an object and transaction B wants to read that object, B must wait until A commits or aborts before it can continue.

Readers never block writers, and writers never block readers.

Because 2PL provides serializability, it protects against all the race conditions discussed earlier, including lost updates and write skew.

### Implementation of two-phase locking

The blocking of readers and writers is implemented by having a lock on each object in the database. The lock can either be in `shared mode` or in `exclusive mode`. The lock is used as follows:

- If a transaction wants to `read` an object, it must first acquire the lock in `shared mode`. Several transactions are allowed to hold the lock in shared mode simultaneously, but if `another` transaction already has an `exclusive lock` on the object, these transactions must `wait`.
- If a transaction wants to `write` to an object, it must first acquire the lock in `exclusive` mode. No other transaction may hold the lock at the same time (either in shared or in exclusive mode), so if there is `any existing lock` on the object, the transaction must `wait`.
- If a transaction `first reads and then writes` an object, it may `upgrade` its `shared` lock to an `exclusive` lock. The upgrade works the same as getting an exclusive lock directly.
- `After` a transaction has `acquired` the lock, it must `continue to hold the lock until the end of the transaction` (commit or abort). This is where the name “two-phase” comes from: the first phase (while the transaction is executing) is when the locks are acquired, and the second phase (at the end of the transaction) is when all the locks are released.

`deadlock`: transaction A is stuck waiting for transaction B to release its lock, and vice versa.

The database automatically detects deadlocks between transactions and aborts one of them so that the others can make progress.

Performance problem of 2PL:

- transaction throughput and response times of queries are significantly worse under two-phase locking than under weak isolation.
- when a transaction is aborted due to deadlock and is retried, it needs to do its work all over again.

### Predicate lock

- If transaction A wants to read objects matching some condition, like in that SELECT query, it must acquire a shared-mode predicate lock on the conditions of the query. If another transaction B currently has an exclusive lock on any object matching those conditions, A must wait until B releases its lock before it is allowed to make its query.
- If transaction A wants to insert, update, or delete any object, it must first check whether either the old or the new value matches any existing predicate lock. If there is a matching predicate lock held by transaction B, then A must wait until B has committed or aborted before it can continue.

Predicate lock applies even to objects that do not yet exist in the database, but which might be added in the future (phantoms).

Predicate locks do not perform well: if there are many locks by active transactions, checking for matching locks becomes time-consuming.

### Index-range locks

`index-range locking` (also known as `next-key locking`): an approximation of the search condition is attached to one of the indexes.

Index-range locks are not as precise as predicate locks would be (they may lock a bigger range of objects than is strictly necessary to maintain serializability), but since they have much lower overheads, they are a good compromise.

## Serializable Snapshot Isolation (SSI)

`Two-phase locking` is a so-called `pessimistic` concurrency control mechanism: it is based on the principle that if anything might possibly go wrong (as indicated by a lock held by another transaction), it’s better to wait until the situation is safe again before doing anything. It is like mutual exclusion, which is used to protect data structures in multi-threaded programming.

`Serializable snapshot isolation` is an `optimistic` concurrency control technique. Optimistic in this context means that instead of blocking if something potentially dangerous happens, transactions continue anyway, in the hope that everything will turn out all right. When a transaction wants to commit, the database checks whether anything bad happened (i.e., whether isolation was violated); if so, the transaction is aborted and has to be retried. Only transactions that executed serializably are allowed to commit.

On top of snapshot isolation, SSI adds an algorithm for detecting serialization conflicts among writes and determining which transactions to abort.

How does the database know if a query result might have changed?

- Detecting reads of a stale MVCC object version (uncommitted write occurred before the read)
  - When the transaction wants to commit, the database checks whether any of the ignored writes have now been committed. If so, the transaction must be aborted.
  - By avoiding unnecessary aborts, SSI preserves snapshot isolation’s support for long-running reads from a consistent snapshot.
- Detecting writes that affect prior reads (the write occurs after the read)
  - When a transaction writes to the database, it must look in the indexes for any other transactions that have recently read the affected data. This process is similar to acquiring a write lock on the affected key range, but rather than blocking until the readers have committed, the lock acts as a tripwire: it simply notifies the transactions that the data they read may no longer be up to date.

Performance of SSI:

- the big `advantage` of serializable snapshot isolation
  - one transaction doesn’t need to block waiting for locks held by another transaction.
  - not limited to the throughput of a single CPU core
- The rate of aborts significantly affects the overall performance of SSI.
  - a transaction that reads and writes data over a long period of time is likely to run into conflicts and abort, so SSI requires that read-write transactions be fairly short (long-running read-only transactions may be okay). However, SSI is probably less sensitive to slow transactions than two-phase locking or serial execution.

# Summary

Race conditions:

- Dirty reads
  - One client reads another client’s writes before they have been committed. The read committed isolation level and stronger levels prevent dirty reads.
- Dirty writes
  - One client overwrites data that another client has written, but not yet committed. Almost all transaction implementations prevent dirty writes.
- Read skew
  - A client sees different parts of the database at different points in time. Some cases of read skew are also known as nonrepeatable reads. This issue is most commonly prevented with snapshot isolation, which allows a transaction to read from a consistent snapshot corresponding to one particular point in time. It is usually implemented with multi-version concurrency control (MVCC).
- Lost updates
  - Two clients concurrently perform a read-modify-write cycle. One overwrites the other’s write without incorporating its changes, so data is lost. Some implementations of snapshot isolation prevent this anomaly automatically, while others require a manual lock (SELECT FOR UPDATE).
- Write skew
  - A transaction reads something, makes a decision based on the value it saw, and writes the decision to the database. However, by the time the write is made, the premise of the decision is no longer true. Only serializable isolation prevents this anomaly.
- Phantom reads
  - A transaction reads objects that match some search condition. Another client makes a write that affects the results of that search. Snapshot isolation prevents straightforward phantom reads, but phantoms in the context of write skew require special treatment, such as index-range locks.

Approaches implementing serializable transactions

- Literally executing transactions in a serial order
  - If you can make each transaction very fast to execute, and the transaction throughput is low enough to process on a single CPU core, this is a simple and effective option.
- Two-phase locking
  - For decades this has been the standard way of implementing serializability, but many applications avoid using it because of its performance characteristics.
- Serializable snapshot isolation (SSI)
  - A fairly new algorithm that avoids most of the downsides of the previous approaches. It uses an optimistic approach, allowing transactions to proceed without blocking. When a transaction wants to commit, it is checked, and it is aborted if the execution was not serializable.

#### Reference

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch07.html>
