---
layout: post
title: Ch11 Stream Processing
date: 2021-08-09 19:36:00
comment_id: 187
categories: [Data Systems, System Design]
---

The `problem` with `daily batch processes` is that changes in the input are only reflected in the output a day later, which is too `slow` for many impatient users.

`event streams`: the unbounded, incrementally processed counterpart to the batch data

# Transmitting Event Streams

`event`: a small, self-contained, immutable object containing the details of something that happened at some point in time. An event usually contains a timestamp indicating when it happened according to a time-of-day clock.

`producer/publisher/sender`: generate event. writes every event that it generates to the datastore

`consumer/subscriber`: potentially process event. periodically polls the datastore to check for events that have appeared since it last ran.

`topic/steam`: event grouped together

## Messaging System

A common approach for notifying consumers about new events is to use a `messaging system`: a producer sends a message containing the event, which is then pushed to consumers.

Messaging system allows `multiple producer` nodes to send messages to the same topic and `allows multiple consumer` nodes to receive messages in a topic.

- What happens if the producers send messages faster than the consumers can process them?
  - three options:
    - the system can drop messages
    - buffer messages in a queue
    - apply backpressure (also known as flow control; i.e., blocking the producer from sending more messages).
- What happens if nodes crash or temporarily go offline—are any messages lost?
  - As with databases, durability may require some combination of writing to disk and/or replication, which has a cost. If you can afford to sometimes lose messages, you can probably get higher throughput and lower latency on the same hardware.

### Message brokers

`message broker/message queue`: a kind of database that is optimized for handling message streams. It runs as a server, with producers and consumers connecting to it as clients. Producers write messages to the broker, and consumers receive them by reading them from the broker.

A consequence of queueing is also that `consumers are generally asynchronous`: when a producer sends a message, it normally only waits for the broker to confirm that it has buffered the message and does not wait for the message to be processed by consumers.

### Message brokers compared to databases

- data storage:
  - `Database` keep data until it is explicitly deleted
  - `message brokers` automatically delete a message when it has been successfully delivered to its consumers. message brokers are not suitable for long-term data storage. Most message brokers assume that their working set is fairly small—i.e., `the queues are short`. If the broker needs to buffer a lot of messages because the consumers are slow (perhaps spilling messages to disk if they no longer fit in memory), each individual message takes longer to process, and the overall throughput may degrade
- search
  - `Databases` often support `secondary indexes` and various ways of searching for data
  - `message brokers` often support some way of `subscribing to a subset of topics matching some pattern`.
- query
  - When querying a `database`, the result is typically based on a point-in-time snapshot of the data; if another client subsequently writes something to the database that changes the query result, the first client does not find out that its prior result is now outdated (unless it repeats the query, or polls for changes).
  - `message brokers` do not support arbitrary queries, but they do notify clients when data changes (i.e., when new messages become available).

### Multiple consumers

When multiple consumers read messages in the same topic, two main patterns of messaging are used:

- Load balancing
  - Each message is delivered to `one` of the consumers, so the consumers can share the work of processing the messages in the topic. The broker may assign messages to consumers arbitrarily. T`his pattern is useful when the messages are expensive to process`, and so you want to be able to add consumers to parallelize the processing.
- Fan-out
  - Each message is delivered to `all` of the consumers. Fan-out allows several independent consumers to each “tune in” to the same broadcast of messages, without affecting each other—the streaming equivalent of `having several different batch jobs that read the same input file`.

### Acknowledgments and redelivery

`acknowledgments`: a client must explicitly tell the broker when it has finished processing a message so that the broker can remove it from the queue.

If the connection to a client is closed or times out without the broker receiving an acknowledgment, it assumes that the message was not processed, and therefore it delivers the message again to another consumer.

## Partitioned Logs

### Using logs for message storage

A producer sends a message by appending it to the end of the log, and a consumer receives messages by reading the log sequentially. If a consumer reaches the end of the log, it waits for a notification that a new message has been appended.

The log can be `partitioned`. Different partitions can then be hosted on different machines, making each partition a separate log that can be read and written independently from other partitions. A topic can then be defined as a group of partitions that all carry messages of the same type.

### Logs compared to traditional messaging

To achieve load balancing across a group of consumers,the broker can assign entire partitions to nodes in the consumer group.

When a consumer has been assigned a log partition, it reads the messages `in the partition sequentially`, in a straightforward single-threaded manner.

downside:

- The number of nodes sharing the work of consuming a topic can be at most the number of log partitions in that topic, because messages within the same partition are delivered to the same node.
- If a single message is slow to process, it holds up the processing of subsequent messages in that partition

How to pick which partition:

- JMS/AMQP style of message broker
  - where messages may be expensive to process
  - and you want to parallelize processing on a message-by-message basis
  - where message ordering is not so important
- log-based
  - high message throughput
  - where each message is fast to process
  - where message ordering is important

Since partitioned logs typically preserve message ordering only within a single partition, `all messages that need to be ordered consistently need to be routed to the same partition`.

### Consumer offsets

All messages with an offset less than a consumer’s current offset have already been processed, and all messages with a greater offset have not yet been seen. `The broker only needs to periodically record the consumer offsets.`

`If a consumer node fails`, another node in the consumer group is assigned the failed consumer’s partitions, and it `starts consuming messages at the last recorded offset`. If the consumer had processed subsequent messages but not yet recorded their offset, those messages `will be processed a second time upon restart`.

### Disk space usage

To reclaim disk space, the log is actually divided into segments, and from time to time old segments are deleted or moved to archive storage.

`circular buffer/ring buffer`: the log implements a bounded-size buffer that discards old messages when it gets full

Regardless of how long you retain messages, the throughput of a log remains more or less constant, since every message is written to disk anyway.

### When consumers cannot keep up with producers

The log-based approach is a form of `buffering with a large but fixed-size buffer`.

advantage: you can experimentally consume a production log for development, testing, or debugging purposes, without having to worry much about disrupting production services. When a consumer is shut down or crashes, it stops consuming resources—the only thing that remains is its consumer offset.

### Replaying old messages

Log-based message broker, consuming messages is more like reading from a file: it is a `read-only operation that does not change the log`. Only consumer offset moves forward.

# Databases and Streams

`Replication log` is a `stream` of database write events, produced by the leader as it processes transactions. The followers apply that stream of writes to their own copy of the database and thus end up with an accurate copy of the same data. The events in the replication log describe the data changes that occurred.

## Keeping Systems in Sync

`dual writes`: the application code explicitly writes to each of the systems when data changes.

problem:
- concurrent problem: concurrent writes occurred—one value will simply silently overwrite another value.
- fault-tolerance problem: one of the writes may fail while the other succeeds

## Change Data Capture

`change data capture (CDC)`: observing all data changes written to a database and extracting them in a form in which they can be replicated to other systems

### Implementing change data capture

Change data capture is a mechanism for ensuring that all changes made to the system of record are also reflected in the derived data systems so that the derived systems have an accurate copy of the data.

Change data capture makes one database the leader (the one from which the changes are captured), and turns the others into followers.

Change data capture is usually `asynchronous`: the system of record database does not wait for the change to be applied to consumers before committing it. This design has the operational `advantage` that `adding a slow consumer does not affect the system of record too much`, but it has the `downside` that all the `issues of replication lag` apply.

### Initial snapshot

The snapshot of the database must correspond to a `known position` or `offset` `in the change log`, so that you know at which point to start applying changes after the snapshot has been processed.

### Log compaction

`log compaction`: the storage engine periodically looks for log records with the same key, throws away any duplicates, and keeps only the most recent update for each key. This compaction and merging process runs in the `background`.

The CDC system is set up such that every change has a primary key, and every update for a key replaces the previous value for that key, then it’s sufficient to keep just the most recent write for a particular key. Now, whenever you want to rebuild a derived data system such as a search index, you can start a new consumer from offset 0 of the log-compacted topic, and sequentially scan over all messages in the log. The log is guaranteed to contain the most recent value for every key in the database (and maybe some older values)—in other words, you can use it to obtain a full copy of the database contents without having to take another snapshot of the CDC source database.

## Event Sourcing

- In `change data capture`, the application uses the database in a `mutable` way, updating and deleting records at will. The log of changes is extracted from the database at a low level (e.g., by parsing the replication log), which ensures that the order of writes extracted from the database matches the order in which they were actually written, avoiding the race condition. The application writing to the database does not need to be aware that CDC is occurring.
- In `event sourcing`, the application logic is explicitly built on the basis of `immutable` events that are written to an event log. In this case, the event store is append-only, and updates or deletes are discouraged or prohibited. Events are designed to reflect things that happened at the application level, rather than low-level state changes.

### Deriving current state from the event log

- A `CDC` event for the update of a record typically contains the entire new version of the record, so the current value for a primary key is entirely determined by the most recent event for that primary key, and log compaction can discard previous events for the same key.
- with `event sourcing`, events are modeled at a higher level: an event typically expresses the intent of a user action. In this case, later events typically do not override prior events, and so you `need the full history of events to reconstruct the final state`. Log compaction is not possible in the same way.

### Commands and events

When a request from a user first arrives, it is initially a `command`: at this point it may still fail, for example because some integrity condition is violated. The application must first validate that it can execute the command. If the validation is successful and the command is accepted, it becomes an `event`, which is durable and immutable. When the event is generated, it becomes a `fact`.

## State, Streams, and Immutability

Mutable state and an append-only log of immutable events do not contradict each other.

### Concurrency control

The biggest `downside` of `event sourcing` and `change data capture` is that the `consumers of the event log are usually asynchronous`, so there is a possibility that a user may make a write to the log, then read from a log-derived view and find that their write has not yet been reflected in the read view.

One solution would be to perform the updates of the read view synchronously with appending the event to the log. This requires a transaction to combine the writes into an atomic unit, so either you need to keep the event log and the read view in the same storage system, or you need a distributed transaction across the different systems.

# Processing Streams

what you can do with the stream once you have it:

- take the data in the events and write it to a database, cache, search index, or similar storage system, from where it can then be queried by other clients.
- push the events to users in some way
- process one or more input streams to produce one or more output streams. Streams may go through a pipeline consisting of several such processing stages before they eventually end up at an output (option 1 or 2).

`operator/job`: A piece of code that processes streams like processing streams to produce other, derived streams.

## Uses of Stream Processing

### Complex event processing

`Complex event processing (CEP)` allows you to specify rules to search for certain patterns of events in a stream.

CEP systems often use a high-level declarative query language like `SQL`, or a `graphical user interface`, to describe the patterns of events that should be detected. These queries are submitted to a processing engine that consumes the input streams and internally maintains a state machine that performs the required matching. When a match is found, the engine emits a `complex event` (hence the name) with the details of the event pattern that was detected.

CEP engines `queries are stored long-term`, and events from the input streams continuously flow past them in search of a query that matches an event pattern.

### Stream analytics

Analytics more oriented toward aggregations and statistical metrics over a large number of events. Such statistics are usually computed over fixed time intervals. The time interval over which you aggregate is known as a `window`.

### Maintaining materialized views

`Maintaining materialized views`: deriving an alternative view onto some dataset so that you can query it efficiently, and updating that view whenever the underlying data changes.

In event sourcing, application state is maintained by applying a log of events; here the application state is also a kind of materialized view.

## Reasoning About Time

### Knowing when you’re ready

Handle such straggler events that arrive after the window has already been declared complete. 2 options:

- Ignore the straggler events, as they are probably a small percentage of events in normal circumstances. You can track the number of dropped events as a metric, and alert if you start dropping a significant amount of data.
- Publish a correction, an updated value for the window with stragglers included. You may also need to retract the previous output.

### Whose clock are you using, anyway?

To adjust for incorrect device clocks, one approach is to log three timestamps:

- The time at which the event occurred, according to the device clock
- The time at which the event was sent to the server, according to the device clock
- The time at which the event was received by the server, according to the server clock

By subtracting the second timestamp from the third, you can estimate the offset between the device clock and the server clock (assuming the network delay is negligible compared to the required timestamp accuracy). You can then apply that offset to the event timestamp, and thus estimate the true time at which the event actually occurred (assuming the device clock offset did not change between the time the event occurred and the time it was sent to the server).

### Types of windows

- Tumbling window
  - A tumbling window has a `fixed length`, and `every event belongs to exactly one window`. You could implement a 1-minute tumbling window by taking each event timestamp and rounding it down to the nearest minute to determine the window that it belongs to.
- Hopping window
  - A hopping window also `has a fixed length`, but `allows windows to overlap` in order to provide some smoothing. You can implement this hopping window by first calculating 1-minute tumbling windows, and then aggregating over several adjacent windows.
- Sliding window
  - A sliding window contains all the events that occur` within some interval of each other`. A sliding window can be implemented by keeping a buffer of events sorted by time and removing old events when they expire from the window.
- Session window
  - a session window has `no fixed duration`. Instead, it is defined by `grouping together all events for the same user that occur closely together in time`, and the window ends when the user has been inactive for some time (for example, if there have been no events for 30 minutes). Sessionization is a common requirement for website analytics.

## Stream Joins

### Stream-stream join (window join)

A stream processor needs to `maintain state`: for example, all the events that occurred in the last hour, indexed by session ID. Whenever a search event or click event occurs, it is added to the appropriate index, and the stream processor also checks the other index to see if another event for the same session ID has already arrived. If there is a matching event, you emit an event saying which search result was clicked. If the search event expires without you seeing a matching click event, you emit an event saying which search results were not clicked.

### Stream-table join (stream enrichment)

One approach is the stream process needs to look at one activity event at a time, look up the event’s user ID in the database, and add the profile information to the activity event. The database lookup could be implemented by querying a `remote` database, however such remote queries are likely to be slow and risk overloading the database.

Another approach is `load a copy` of the database into the stream processor so that it can be queried locally without a network round-trip. the local copy of the database might be an in-memory hash table if it is small enough, or an index on the local disk. The stream processor’s local copy of the database `needs to be kept up to date`. This issue can be solved by `change data capture`: the stream processor can subscribe to a changelog of the user profile database as well as the stream of activity events.

### Table-table join (materialized view maintenance)

One approach is streams of events for tweets (sending and deleting) and for follow relationships (following and unfollowing). The stream process needs to maintain a database containing the set of followers for each user so that it knows which timelines need to be updated when a new tweet arrives.

Another approach is stream process maintains a materialized view for a query that joins two tables (tweets and follows). The join of the streams corresponds directly to the join of the tables in that query. The timelines are effectively a cache of the result of this query, updated every time the underlying tables change.

### Time-dependence of joins

The three types of joins described here (stream-stream, stream-table, and table-table) have a lot in common: t`hey all require the stream processor to maintain some state` based on one join input, and query that state on messages from the other join input.

`slowly changing dimension (SCD)`: If the ordering of events across streams is undetermined, the join becomes nondeterministic, which means you cannot rerun the same job on the same input and necessarily get the same result: the events on the input streams may be interleaved in a different way when you run the job again. It is often addressed by `using a unique identifier for a particular version` of the joined record. `This change makes the join deterministic, but has the consequence that log compaction is not possible, since all versions of the records in the table need to be retained`.

## Fault Tolerance

### Microbatching and checkpointing

- `microbatching`: break the stream into small blocks, and treat each block like a miniature batch process. The batch size is typically around one second, which is the result of a performance compromise. Microbatching also implicitly provides a tumbling window equal to the batch size (windowed by processing time, not event timestamps); any jobs that require larger windows need to explicitly carry over state from one microbatch to the next.
- `checkpoints`: periodically generate rolling checkpoints of state and write them to durable storage. If a stream operator crashes, it can restart from its most recent checkpoint and discard any output generated between the last checkpoint and the crash.

However, as soon as output leaves the stream processor, the framework is no longer able to discard the output of a failed batch. In this case, restarting a failed task causes the external side effect to happen twice, and microbatching or checkpointing alone is not sufficient to prevent this problem.

### Idempotence

`Idempotence`: `perform multiple times, and it has the same effect as if you performed it only once`. For example, setting a key in a key-value store to some fixed value is idempotent (writing the value again simply overwrites the value with an identical value), whereas incrementing a counter is not idempotent (performing the increment again means the value is incremented twice).

### Rebuilding state after a failure

Keep state local to the stream processor, and replicate it periodically. Then, when the stream processor is recovering from a failure, the new task can read the replicated state and resume processing without data loss.

# Summary

two types of message brokers:

- AMQP/JMS-style message broker
  - The broker assigns individual messages to consumers, and consumers acknowledge individual messages when they have been successfully processed. Messages are deleted from the broker once they have been acknowledged. This approach is appropriate as an asynchronous form of RPC
- Log-based message broker
  - The broker assigns all messages in a partition to the same consumer node, and always delivers messages in the same order. Parallelism is achieved through partitioning, and consumers track their progress by checkpointing the offset of the last message they have processed. The broker retains messages on disk, so it is possible to jump back and reread old messages if necessary.

three types of joins that may appear in stream processes:

- Stream-stream joins
  - Both input streams consist of activity events, and the join operator searches for related events that occur within some window of time. For example, it may match two actions taken by the same user within 30 minutes of each other. The two join inputs may in fact be the same stream (a self-join) if you want to find related events within that one stream.
- Stream-table joins
  - One input stream consists of activity events, while the other is a database changelog. The changelog keeps a local copy of the database up to date. For each activity event, the join operator queries the database and outputs an enriched activity event.
- Table-table joins
  - Both input streams are database changelogs. In this case, every change on one side is joined with the latest state of the other side. The result is a stream of changes to the materialized view of the join between the two tables.

#### Reference

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch11.html>
