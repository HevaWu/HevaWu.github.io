---
layout: post
title: Ch10 Batch Processing
date: 2021-08-08 19:36:00
comment_id: 186
categories: [Data Systems, System Design]
tags: [Designing Data Intensive Applications]
---

Three different types of systems:

- Services (online systems)
  - A service waits for a request or instruction from a client to arrive. When one is received, the service tries to handle it as quickly as possible and sends a response back. Response time is usually the primary measure of performance of a service, and availability is often very important (if the client can’t reach the service, the user will probably get an error message).
- Batch processing systems (offline systems)
  - A batch processing system takes a large amount of input data, runs a job to process it, and produces some output data. Jobs often take a while (from a few minutes to several days), so there normally isn’t a user waiting for the job to finish. Instead, `batch jobs are often scheduled to run periodically` (for example, once a day). The primary performance measure of a batch job is usually throughput (the time it takes to crunch through an input dataset of a certain size).
- Stream processing systems (near-real-time systems)
  - Stream processing is somewhere between online and offline/batch processing (so it is sometimes called near-real-time or nearline processing). Like a batch processing system, a stream processor consumes inputs and produces outputs (rather than responding to requests). However, a stream job operates on events shortly after they happen, whereas a batch job operates on a fixed set of input data. This difference allows `stream processing systems to have lower latency` than the equivalent batch systems.

# Batch Processing with Unix Tools

Unix philosophy:

- Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new “features”.
- Expect the output of every program to become the input to another, as yet unknown, program. Don’t clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don’t insist on interactive input.
- Design and build software, even operating systems, to be tried early, ideally within weeks. Don’t hesitate to throw away the clumsy parts and rebuild them.
- Use tools in preference to unskilled help to lighten a programming task, even if you have to detour to build the tools and expect to throw some of them out after you’ve finished using them.

Characteristic feature:

- A uniform interface
  - If you expect the output of one program to become the input to another program, that means those programs must use the same data format—in other words, a `compatible interface`.
- separation of logic and writing
  - use of standard input (stdin) and standard output (stdout).
  - `loose coupling/late binding/inversion of control`: allows a shell user to wire up the input and output in whatever way they want; the program doesn’t know or care where the input is coming from and where the output is going to.
- transparency and experimentation
  - The input files to Unix commands are normally treated as immutable. This means you can run the commands as often as you want, trying various command-line options, without damaging the input files
  - You can end the pipeline at any point, pipe the output into less, and look at it to see if it has the expected form. This ability to inspect is great for debugging.
  - You can write the output of one pipeline stage to a file and use that file as input to the next stage. This allows you to restart the later stage without rerunning the entire pipeline.
  - limitation: run only on a single machine

# MapReduce and Distributed Filesystems

HDFS(Hadoop Distributed File System) is based on the `shared-nothing` principle. The shared-nothing approach requires no special hardware, only computers connected by a conventional datacenter network.

HDFS consists of a daemon process running on each machine, exposing a network service that allows other nodes to access files stored on that machine (assuming that every general-purpose machine in a datacenter has some disks attached to it). A central server called the NameNode keeps track of which file blocks are stored on which machine. Thus, HDFS conceptually creates one big filesystem that can use the space on the disks of all machines running the daemon.

In order to tolerate machine and disk failures, file blocks are replicated on multiple machines.

## MapReduce Job Execution

MapReduce is a programming framework with which you can write code to process large datasets in a distributed filesystem like HDFS.

1. (breaking files into record) Read a set of input files, and break it up into records.
2. (map) Call the mapper function to extract a key and value from each input record.
3. (sort - implicit) Sort all of the key-value pairs by key.
4. (reduce) Call the reducer function to iterate over the sorted key-value pairs. If there are multiple occurrences of the same key, the sorting has made them adjacent in the list, so it is easy to combine those values without having to keep a lot of state in memory.

To create a MapReduce job, you need to implement two callback functions, the mapper and reducer:

- Mapper
  - The mapper is `called once` for every input record, and its job is to extract the key and value from the input record. For each input, it may generate any number of key-value pairs (including none). It does not keep any state from one input record to the next, so each record is handled `independently`.
- Reducer
  - The MapReduce framework `takes the key-value pairs` produced by the mappers, collects all the values belonging to the same key, and calls the reducer with an iterator over that collection of values. The reducer can produce output records

### Distributed execution of MapReduce

MapReduce `can parallelize a computation across many machines`, without you having to write code to explicitly handle the parallelism.

`putting the computation near the data`: it saves copying the input file over the network, reducing network load and increasing locality.

- MapReduce framework first copies the code to the appropriate machines.
- starts the `map` task and begins reading the input file, passing one record at a time to the mapper callback. The output of the mapper consists of key-value pairs.
- The `reduce` side of the computation is also partitioned. While the number of map tasks is determined by the number of input file blocks, the number of reduce tasks is configured by the job author (it can be different from the number of map tasks). To ensure that all key-value pairs with the same key end up at the same reducer, the framework uses a `hash` of the key to determine which reduce task should receive a particular key-value pair
- sorting is performed in stages
  - First, each map task partitions its output by reducer, based on the hash of the key. Each of these partitions is written to a sorted file on the mapper’s local disk
  - Whenever a mapper finishes reading its input file and writing its sorted output files, the MapReduce scheduler notifies the reducers that they can start fetching the output files from that mapper. The reducers connect to each of the mappers and download the files of sorted key-value pairs for their partition.
  - The reduce task takes the files from the mappers and merges them together, preserving the sort order.

### MapReduce workflows

For MapReduce jobs to be chained together into `workflows`, such that the output of one job becomes the input to the next job.

`Chained MapReduce jobs` like a sequence of commands where each command’s output is written to a temporary file, and the next command reads from the temporary file.

`A batch job’s output is only considered valid when the job has completed successfully` (MapReduce discards the partial output of a failed job). Therefore, one job in a workflow can only start when the prior jobs—that is, the jobs that produce its input directories—have completed successfully.

Workflows consisting of 50 to 100 MapReduce jobs are common when building recommendation systems.

## Reduce-Side Joins and Grouping

In many datasets it is common for one record to have an association with another record: a `foreign key` in a relational model, a `document reference` in a document model, or an `edge` in a graph model.

A join is necessary whenever you have some code that needs to access records on both sides of that association (both the record that holds the reference and the record being referenced).

`full table scan`: When a MapReduce job is given a set of files as input, it reads the entire content of all of those files;

`sort-merge join`: mapper output is sorted by key, and the reducers then merge together the sorted lists of records from both sides of the join.

`grouping records by some key`: common use of the “bringing related data to the same place” pattern. All records with the same key form a group, and the next step is often to perform some kind of aggregation within each group.

`hot keys/linchpin objects`: a very large amount of data related to a single key

`skew/hot spots`: one reducer that must process significantly more records than the others

If join input has hot keys:

- skewed join
  - first runs a sampling job to determine which keys are hot. When performing the actual join, the mappers send any records relating to a hot key to one of several reducers, chosen at random (in contrast to conventional MapReduce, which chooses a reducer deterministically based on a hash of the key). For the other input to the join, records relating to the hot key need to be replicated to all reducers handling that key.
- shared join
  - requires the hot keys to be specified explicitly rather than using a sampling job
  - using randomization to alleviate hot spots in a partitioned database.
- Hive’s skewed join
  - requires hot keys to be specified explicitly in the table metadata, and it stores records related to those keys in separate files from the rest. When performing a join on that table, it uses a map-side join (see the next section) for the hot keys.

## Map-Side Joins

- reduce-side joins
  - mappers take the role of preparing the input data: extracting the key and value from each input record, assigning the key-value pairs to a reducer partition, and sorting by key.
  - advantage: do not need to make any assumptions about the input data: whatever its properties and structure, the mappers can prepare the data to be ready for joining.
  - downside: all that sorting, copying to reducers, and merging of reducer inputs can be quite expensive. Depending on the available memory buffers, data may be written to disk several times as it passes through the stages of MapReduce
- map-side join
  - uses a cut-down MapReduce job in which there are no reducers and no sorting. Instead, each mapper simply reads one input file block from the distributed filesystem and writes one output file to the filesystem

### Broadcast hash joins

he simplest way of `performing a map-side join` applies in the case where a large dataset is joined with `a small dataset`. In particular, the small dataset needs to be small enough that it can be loaded entirely into memory in each of the mappers.

`broadcast hash join`: the word `broadcast` reflects the fact that each mapper for a partition of the large input reads the entirety of the small input (so the small input is effectively “broadcast” to all partitions of the large input), and the word `hash` reflects its use of a hash table.

### Partitioned hash joins

`partitioned hash joins/bucketed map joins`: f the inputs to the map-side join are partitioned in the same way, then the hash join approach can be applied to each partition independently.

This approach only works if both of the join’s inputs have the same number of partitions, with records assigned to partitions based on the same key and the same hash function.

### Map-side merge joins

If the input datasets are not only partitioned in the same way, but also sorted based on the same key.

## The Output of Batch Workflows

### Building search indexes

`full-text search index`: it is a file (the term dictionary) in which you can efficiently look up a particular keyword and find the list of all the document IDs containing that keyword (the postings list).

The mappers partition the set of documents as needed, each reducer builds the index for its partition, and the index files are written to the distributed filesystem.

If the indexed set of documents changes, one option is to `periodically rerun the entire indexing` workflow for the entire set of documents, and replace the previous index files wholesale with the new index files when it is done. This approach can be computationally `expensive` if only a small number of documents have changed, but it has the `advantage` that the indexing process is very easy to reason about: documents in, indexes out.

### Key-value stores as batch process output

Build a brand-new database inside the batch job and write it as files to the job’s output directory in the distributed filesystem, just like the search indexes in the last section. Those data files are then immutable once written, and can be loaded in bulk into servers that handle read-only queries.

### Philosophy of batch process outputs

- If you introduce a bug into the code and the output is wrong or corrupted, you `can simply roll back` to a previous version of the code and rerun the job, and the output will be correct again. Or, even simpler, you can keep the old output in a different directory and simply switch back to it
- As a consequence of this ease of rolling back, feature development can proceed more quickly than in an environment where mistakes could mean irreversible damage. This principle of `minimizing irreversibility` is beneficial for Agile software development
- If a map or reduce task `fails`, the MapReduce framework `automatically re-schedules` it and runs it again on the same input. If the failure is due to a bug in the code, it will keep crashing and eventually cause the job to fail after a few attempts; but if the failure is due to a transient issue, the fault is tolerated. This automatic retry is only safe because inputs are immutable and outputs from failed tasks are discarded by the MapReduce framework.
- The same set of files can be used as input for various different jobs, including monitoring jobs that calculate metrics and evaluate whether a job’s output has the expected characteristics (for example, by comparing it to the output from the previous run and measuring discrepancies).
- MapReduce jobs separate logic from wiring (configuring the input and output directories), which provides a separation of concerns and enables potential reuse of code: one team can focus on implementing a job that does one thing well, while other teams can decide where and when to run that job.

## Comparing Hadoop to Distributed Databases

MPP(massively parallel processing) databases focus on parallel execution of analytic SQL queries on a cluster of machines, while the combination of MapReduce and a distributed filesystem provides something much more like a general-purpose operating system that can run arbitrary programs.

### Diversity of storage

Hadoop has often been used for implementing ETL processes: data from transaction processing systems is dumped into the distributed filesystem in some raw form, and then MapReduce jobs are written to clean up that data, transform it into a relational form, and import it into an MPP data warehouse for analytic purposes. Data modeling still happens, but it is in a separate step, decoupled from the data collection. This decoupling is possible because a distributed filesystem supports data encoded in any format.

### Designing for frequent faults

When comparing, 2 differences stand out: `the handling of faults` and `the use of memory and disk`.

Batch processes are less sensitive to faults than online systems, because they do not immediately affect users if they fail and they can always be run again.

MapReduce can tolerate the failure of a map or reduce task without it affecting the job as a whole by retrying work at the granularity of an individual task. It is also very eager to write data to disk, partly for fault tolerance, and partly on the assumption that the dataset will be too big to fit in memory anyway. `The MapReduce approach is more appropriate for larger jobs`: jobs that process so much data and run for such a long time that they are likely to experience at least one task failure along the way.

Why MapReduce is designed to tolerate frequent unexpected task termination: it’s not because the hardware is particularly unreliable, it’s because the `freedom to arbitrarily terminate processes enables better resource utilization in a computing cluster`.

# Beyond MapReduce

## Materialization of Intermediate State

`intermediate state`: a means of passing data from one job to the next

`materialization`: process of writing out this intermediate state to files

### Dataflow engines

`Dataflow engines`: handle an entire workflow as one job, rather than breaking it up into independent subjobs. explicitly model the flow of data through several processing stages. They parallelize work by partitioning inputs, and they copy the output of one function over the network to become the input to another function.

the dataflow engine provides several different options for connecting one operator’s output to another’s input:

- One option is to repartition and sort records by key, like in the shuffle stage of MapReduce. This feature enables sort-merge joins and grouping in the same way as in MapReduce.
- Another possibility is to take several inputs and to partition them in the same way, but skip the sorting. This saves effort on partitioned hash joins, where the partitioning of records is important but the order is irrelevant because building the hash table randomizes the order anyway.
- For broadcast hash joins, the same output from one operator can be sent to all partitions of the join operator.

advantages:

- Expensive work such as sorting need only be performed in places where it is actually required, rather than always happening by default between every map and reduce stage.
- There are no unnecessary map tasks, since the work done by a mapper can often be incorporated into the preceding reduce operator (because a mapper does not change the partitioning of a dataset).
- Because all joins and data dependencies in a workflow are explicitly declared, the scheduler has an overview of what data is required where, so it can make locality optimizations. For example, it can try to place the task that consumes some data on the same machine as the task that produces it, so that the data can be exchanged through a shared memory buffer rather than having to copy it over the network.
- It is usually sufficient for intermediate state between operators to be kept in memory or written to local disk, which requires less I/O than writing it to HDFS (where it must be replicated to several machines and written to disk on each replica). MapReduce already uses this optimization for mapper output, but dataflow engines generalize the idea to all intermediate state.
- Operators can start executing as soon as their input is ready; there is no need to wait for the entire preceding stage to finish before the next one starts.
- Existing Java Virtual Machine (JVM) processes can be reused to run new operators, reducing startup overheads compared to MapReduce (which launches a new JVM for each task).

### Fault tolerance

An `advantage` of fully materializing intermediate state to a distributed filesystem is that it is durable, i`f a task fails, it can just be restarted on another machine and read the same input again from the filesystem`.

To enable this recomputation, the framework must keep track of how a given piece of data was computed—`which input partitions it used, and which operators were applied to it`. When recomputing data, it is important `to know whether the computation is deterministic`: that is, given the same input data, do the operators always produce the same output? The solution in the case of nondeterministic operators is normally to kill the downstream operators as well, and run them again on the new data.

## Graphs and Iterative Processing

Graph iterative implementation style:

- An external scheduler runs a batch process to calculate one step of the algorithm.
- When the batch process completes, the scheduler checks whether the iterative algorithm has finished (based on the completion condition—e.g., there are no more edges to follow, or the change of a metric compared to the last iteration is below some threshold).
- If the algorithm has not yet finished, the scheduler goes back to step 1 and runs another round of the batch process.

### The Pregel processing model

`BSP(bulk synchronous parallel) model/Pregel model`: In each iteration, a function is called for each vertex, passing the function all the messages that were sent to that vertex—much like a call to the reducer. The difference from MapReduce is that in the Pregel model, a vertex remembers its state in memory from one iteration to the next, so the function only needs to process new incoming messages. If no messages are being sent in some part of the graph, no work needs to be done.

### Fault tolerance

The only waiting is between iterations: since the Pregel model guarantees that all messages sent in one iteration are delivered in the next iteration, the prior iteration must completely finish, and all of its messages must be copied over the network, before the next one can start.

Pregel implementations guarantee that messages are processed exactly once at their destination vertex in the following iteration.

This fault tolerance is achieved by `periodically checkpointing the state of all vertices at the end of an iteration`—i.e., writing their full state to durable storage. If a node fails and its in-memory state is lost, the simplest solution is to roll back the entire graph computation to the last checkpoint and restart the computation at that point. If the algorithm is deterministic and messages are logged, it is also possible to selectively recover only the partition that was lost.

### Parallel execution

Graph algorithms often have a lot of cross-machine communication overhead, and the intermediate state (messages sent between nodes) is often bigger than the original graph. The overhead of sending messages over the network can significantly slow down distributed graph algorithms.

# Summary

The two main problems that distributed batch processing frameworks need to solve are:

- Partitioning
  - In MapReduce, mappers are partitioned according to input file blocks. The output of mappers is repartitioned, sorted, and merged into a configurable number of reducer partitions. The purpose of this process is to bring all the related data—e.g., all the records with the same key—together in the same place.
  - Post-MapReduce dataflow engines try to avoid sorting unless it is required, but they otherwise take a broadly similar approach to partitioning.
- Fault tolerance
  - MapReduce frequently writes to disk, which makes it easy to recover from an individual failed task without restarting the entire job but slows down execution in the failure-free case. Dataflow engines perform less materialization of intermediate state and keep more in memory, which means that they need to recompute more data if a node fails. Deterministic operators reduce the amount of data that needs to be recomputed.

MapReduce join algorithm:

- Sort-merge joins
  - Each of the inputs being joined goes through a mapper that extracts the join key. By partitioning, sorting, and merging, all the records with the same key end up going to the same call of the reducer. This function can then output the joined records.
- Broadcast hash joins
  - One of the two join inputs is small, so it is not partitioned and it can be entirely loaded into a hash table. Thus, you can start a mapper for each partition of the large join input, load the hash table for the small input into each mapper, and then scan over the large input one record at a time, querying the hash table for each record.
- Partitioned hash joins
  - If the two join inputs are partitioned in the same way (using the same key, same hash function, and same number of partitions), then the hash table approach can be used independently for each partition.

#### Reference

- <https://learning.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/ch10.html>
