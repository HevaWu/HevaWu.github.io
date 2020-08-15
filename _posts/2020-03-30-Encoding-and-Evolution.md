---
layout: post
title: Encoding and Evolution
date: 2020-03-30 15:27:00
comment_id: 72
categories: [DataSystems, SystemDesign]
tags: [Encode, Decode]
---

## Overview

In order for the system to continue running smoothly, we need to maintain compatibility in both directions:

- Backward compatiblity: newer code can read data that was written by older one
- Forward compatiblity: older code can read data that was written by newer code

## Formats for Encoding Data

2 representations:

- In memory, data is kept in objects, structs, lists, arrays, hash tables, trees. These data strutures are optimized for efficient acess and manipulation by the CPU(typically using pointers)
- when write data to file or send it over the network, need to `encode` it as some kind of `self-contained sequence` of bytes.

The translation from the in-memory representation to a byte sequence is called `encoding`(also known as `serialization` or `marshalling`), and the reverse is called `decoding` (`parsing`, `deserialization`, `unmarshalling`).

### Language-Specific Formats

Encoding libraries are very convenient, because they `allow in-memory objects to be saved and restored` with minimal additional code. However, they also have a number of deep problems:

- The `encoding` is often tied to `a particular programming` language, and reading the data in another language is very difficult.
- In order to restore data in the same object types, the decoding process needs to be able to `instantiate arbitrary classes`. This is frequently a source of `security` problems: if an attacker can get your application to decode an arbitrary byte sequence, they can instantiate arbitrary classes, which in turn often allows them to do terrible things such as remotely executing arbitrary code.
- `Versioning` data is often an afterthought in these libraries: as they are intended for quick and easy encoding of data, they often neglect the inconvenient problems of `forward and backward compatibility`.
- `Efficiency` (CPU time taken to encode or decode, and the size of the encoded structure) is also often an afterthought.

### JSON, XML and Binary Variants

Moving to standardized encodings that can be written and read by many programming languages, `JSON` and `XML` are the obvious contenders. They are `widely known, widely supported, and almost as widely disliked`. `XML` is often criticized for being too `verbose` and `unnecessarily complicated`. `JSON’s` popularity is mainly due to its `built-in support in web` browsers (by virtue of being a subset of JavaScript) and simplicity relative to XML. `CSV` is another popular language-independent format, albeit less powerful.

`JSON`, `XML`, and `CSV` are `textual` formats, and thus somewhat `human-readable`. Besides the superficial syntactic issues, they also have some subtle problems:

- There is a lot of ambiguity around the `encoding of numbers`. In `XML` and `CSV`, you `cannot distinguish` between a number and a string that happens to consist of digits (except by referring to an external schema). `JSON` distinguishes strings and numbers, but it `doesn’t distinguish integers and floating-point numbers`, and it `doesn’t specify a precision`.
  - This is a problem `when dealing with large numbers`; for example, integers greater than 253 cannot be exactly represented in an IEEE 754 double-precision floating-point number, so such numbers become inaccurate when parsed in a language that uses floating-point numbers (such as JavaScript). An example of numbers larger than 253 occurs on Twitter, which uses a 64-bit number to identify each tweet. The JSON returned by Twitter’s API includes tweet IDs twice, once as a JSON number and once as a decimal string, to work around the fact that the numbers are not correctly parsed by JavaScript applications.
- `JSON` and `XML` have `good` support for `Unicode character strings`, but they `don’t support binary strings` (sequences of bytes without a character encoding). Binary strings are a useful feature, so people get around this limitation by encoding the binary data as text using Base64. The schema is then used to indicate that the value should be interpreted as Base64-encoded. This works, but it’s somewhat hacky and increases the data size by 33%.
- There is optional schema support for both XML and JSON. These schema languages are quite powerful, and thus quite complicated to learn and implement. Use of XML schemas is fairly widespread, but many JSON-based tools don’t bother using schemas. Since the correct interpretation of data (such as numbers and binary strings) depends on information in the schema, applications that don’t use XML/JSON schemas need to potentially hardcode the appropriate encoding/decoding logic instead.
- `CSV` does `not have any schema`, so it is up to the application to define the meaning of each row and column. If an application change adds a new row or column, you have to handle that change manually. CSV is also a quite vague format (what happens if a value contains a comma or a newline character?). Although its escaping rules have been formally specified, not all parsers implement them correctly.

### Binary encoding

JSON is less verbose than XML, but both still use a lot of space compared to binary formats. This observation led to the development of a profusion of binary encodings for JSON (MessagePack, BSON, BJSON, UBJSON, BISON, and Smile, to name a few) and for XML (WBXML and Fast Infoset, for example)

Example:

```markdown
{
    "userName": "Martin",
    "favoriteNumber": 1337,
    "interests": ["daydreaming", "hacking"]
}

The first byte, 0x83, indicates that what follows is an object (top four bits = 0x80) with three fields (bottom four bits = 0x03). (In case you’re wondering what happens if an object has more than 15 fields, so that the number of fields doesn’t fit in four bits, it then gets a different type indicator, and the number of fields is encoded in two or four bytes.)

The second byte, 0xa8, indicates that what follows is a string (top four bits = 0xa0) that is eight bytes long (bottom four bits = 0x08).

The next eight bytes are the field name userName in ASCII. Since the length was indicated previously, there’s no need for any marker to tell us where the string ends (or any escaping).

The next seven bytes encode the six-letter string value Martin with a prefix 0xa6, and so on.

The binary encoding is 66 bytes long, which is only a little less than the 81 bytes taken by the textual JSON encoding (with whitespace removed). All the `binary encodings of JSON` are similar in this regard. It’s not clear whether such a small space reduction (and perhaps a speedup in parsing) is worth the loss of human-readability.
```

### Thrift and Protocol Buffers

`Apache Thrift` and `Protocol Buffers` (protobuf) are `binary encoding libraries` that are based on the same principle. `Protocol Buffers` was originally developed at Google, `Thrift` was originally developed at Facebook, and both were made open source in 2007–08.

`Thrift` has two different binary encoding formats,iii called `BinaryProtocol` and `CompactProtocol`, respectively.

### Field tags and schema evolution

You can change the name of a field in the schema, since the encoded data never refers to field names, but you `cannot` `change a field’s tag`, since that would make all existing encoded data invalid.

You can `add new fields to the schema`, provided that you give each field a new tag number. If old code (which doesn’t know about the new tag numbers you added) tries to read data written by new code, including a new field with a tag number it doesn’t recognize, it can simply ignore that field. The datatype annotation allows the parser to determine how many bytes it needs to skip. This maintains forward compatibility: old code can read records that were written by new code.

The only detail is that if you `add a new field, you cannot make it required.` If you were to add a field and make it required, that check would fail if new code read data written by old code, because the old code will not have written the new field that you added.

Removing a field is just like adding a field, with backward and forward compatibility concerns reversed. That means you `can only remove a field that is optional` (a required field can never be removed), and you can `never use the same tag number again` (because you may still have data written somewhere that includes the old tag number, and that field must be ignored by new code).

### Datatypes and schema evolution

A curious detail of `Protocol Buffers` is that it `does not have a list or array datatype`, but instead has a `repeated` marker for fields (which is a third option alongside required and optional). The encoding of a repeated field is just what it says on the tin: `the same field tag simply appears multiple times in the record`. This has the nice effect that it’s okay to change an optional (single-valued) field into a repeated (multi-valued) field. New code reading old data sees a list with zero or one elements (depending on whether the field was present); old code reading new data sees only the last element of the list.

`Thrift` has a dedicated list datatype, which is parameterized with the datatype of the list elements. This `does not`allow the same evolution `from single-valued to multi-valued` as Protocol Buffers does, but it has the `advantage` of `supporting nested lists`.

### Avro

`Apache Avro` is another binary encoding format which started in 2009 as a subproject of Hadoop.

Avro also uses a schema to specify the structure of the data being encoded. It has two schema languages: one (`Avro IDL`) intended for `human editing`, and one (`based on JSON`) that is more easily `machine-readable`.

**The writer's schema and the reader's schema**

With `Avro`, when an application wants to `encode` some data (to write it to a file or database, to send it over the network, etc.), it encodes the data using whatever version of the schema it knows about—for example, that schema may be compiled into the application. This is known as the `writer’s schema`.

When an application wants to `decode` some data (read it from a file or database, receive it from the network, etc.), it is expecting the data to be in some schema, which is known as the `reader’s schema`. That is the schema the application code is relying on—code may have been generated from that schema during the application’s build process.

The key idea with Avro is that `the writer’s schema and the reader’s schema` `don’t have to be the same`—they `only` `need` to be `compatible`.

**Schema Evolution Rules**

To maintain compatibility, you may `only add or remove` a field that `has a default` value. If you were to add a field that has no default value, new readers wouldn’t be able to read data written by old writers, so you would break backward compatibility. If you were to remove a field that has no default value, old readers wouldn’t be able to read data written by new writers, so you would break forward compatibility.

You can only use null as a default value if it is one of the branches of the union.iv This is a little more verbose than having everything nullable by default, but it helps prevent bugs by being explicit about what can and cannot be null. `Avro` `doesn’t` have `optional` and `required` markers.

Example:

```markdown
Avro writer's schema 

- Large file with lots of records
  - A common use for Avro—especially in the context of Hadoop—is for storing a large file containing millions of records, all encoded with the same schema. (We will discuss this kind of situation in Chapter 10.) In this case, the writer of that file can just include the writer’s schema once at the beginning of the file. Avro specifies a file format (object container files) to do this.

- Database with individually written records
  - In a database, different records may be written at different points in time using different writer’s schemas—you cannot assume that all the records will have the same schema. The simplest solution is to include a version number at the beginning of every encoded record, and to keep a list of schema versions in your database. A reader can fetch a record, extract the version number, and then fetch the writer’s schema for that version number from the database. Using that writer’s schema, it can decode the rest of the record. (Espresso [23] works this way, for example.)

- Sending records over a network connection
  - When two processes are communicating over a bidirectional network connection, they can negotiate the schema version on connection setup and then use that schema for the lifetime of the connection. The Avro RPC protocol (see “Dataflow Through Services: REST and RPC”) works like this.
```

**Dynamically Generated Schemas**

`Avro` is friendlier to `dynamically generated` schemas. If the database schema changes (for example, a table has one column added and one column removed), you can just generate a new Avro schema from the updated database schema and export data in the new Avro schema. The data export process does not need to pay any attention to the schema change—it can simply do the schema conversion every time it runs. Anyone who reads the new data files will see that the fields of the record have changed, but since the fields are identified by name, the updated writer’s schema can still be matched up with the old reader’s schema.

By contrast, if you were using Thrift or Protocol Buffers for this purpose, the field tags would likely have to be assigned by hand: every time the database schema changes, an administrator would have to manually update the mapping from database column names to field tags. (It might be possible to automate this, but the schema generator would have to be very careful to not assign previously used field tags.) This kind of dynamically generated schema simply wasn’t a design goal of Thrift or Protocol Buffers, whereas it was for Avro.

**Code Generation and Dynamically typed Languages**

`Thrift` and `Protocol Buffers` rely on `code generation`: after a schema has been defined, you can generate code that implements this schema in a programming language of your choice. This is `useful` in `statically typed language`s such as Java, C++, or C#, because it allows efficient in-memory structures to be used for decoded data, and it allows type checking and autocompletion in IDEs when writing programs that access the data structures.

In `dynamically typed programming languages` such as JavaScript, Ruby, or Python, there is not much point in generating code, since there is no compile-time type checker to satisfy. `Code generation` is often frowned upon in these languages, since they otherwise avoid an explicit compilation step. Moreover, in the case of a dynamically generated schema (such as an Avro schema generated from a database table), code generation is an unnecessary obstacle to getting to the data.

`Avro` provides `optional` `code generation` for statically typed programming languages, but it can be used just as well without any code generation. If you have an object container file (which embeds the writer’s schema), you can simply open it using the Avro library and look at the data in the same way as you could look at a JSON file.

### The Merits of Schemas

Although textual data formats such as JSON, XML, and CSV are widespread, `binary encodings based on schemas` are also a viable option. They have a number of nice `properties`:

- They can be much more `compact` than the various “binary JSON” variants, since they can omit field names from the encoded data.
- The schema is a `valuable` form of documentation, and because the schema is required for decoding, you can be sure that it is `up to date` (whereas manually maintained documentation may easily diverge from reality).
- Keeping a database of schemas allows you to `check forward and backward compatibility` of schema changes, before anything is deployed.
- For users of statically typed programming languages, the ability to generate code from the schema is useful, since it `enables type checking` at compile time.

`Schema evolution` `allows` the same kind of `flexibility as schemaless/schema-on-read` JSON databases provide, while also providing better guarantees about your data and better tooling.

## Modes of Dataflow

### Dataflow Through Databases

In a database, the process that writes to the database encodes the data, and the process that reads from the database decodes it.

`Backward compatibility is clearly necessary here`; otherwise your future self won’t be able to decode what you previously wrote. A value in the database may be written by a newer version of the code, and subsequently read by an older version of the code that is still running. Thus, `forward compatibility is also often required `for databases.

The encoding formats discussed previously support such preservation of unknown fields, but sometimes you need to take care at an application level.

**Different Values Written at Different Times**

When you deploy a new version of your application (of a server-side application, at least), you may entirely replace the old version with the new version within a few minutes. The same is not true of database contents: the five-year-old data will still be there, in the original encoding, unless you have explicitly rewritten it since then. This observation is sometimes summed up as `data outlives code`.

`Rewriting` (`migrating`) data into a new schema is certainly possible, but it’s an expensive thing to do on a large dataset, so most databases avoid it if possible. Most relational databases `allow simple schema changes`, such as adding a new column with a null default value, without rewriting existing data.When an old row is read, the database fills in nulls for any columns that are missing from the encoded data on disk.

### Dataflow Through Services: REST and RPC

When you have processes that need to `communicate over a network`, there are a few different ways of arranging that communication. The most common arrangement is to have two roles: `clients` and `servers`. The servers expose an API over the network, and the clients can connect to the servers to make requests to that API. The API exposed by the server is known as a service.

The web works this way: `clients` (web browsers) make `requests` to web `servers`, making GET requests to download HTML, CSS, JavaScript, images, etc., and making POST requests to submit data to the server. The API consists of a standardized set of protocols and data formats (HTTP, URLs, SSL/TLS, HTML, etc.). Because web browsers, web servers, and website authors mostly agree on these standards, you can use any web browser to access any website (at least in theory!).

A server can itself be a client to another service (for example, a typical web app server acts as client to a database). This approach is often used to decompose a large application into smaller services by area of functionality, such that one service makes a request to another when it requires some functionality or data from that other service. This way of building applications has traditionally been called a `service-oriented architecture (SOA)`, more recently refined and rebranded as `microservices architecture`.

A `key` design goal of a `service-oriented/microservices architecture` is to `make the application easier to change and maintain` by making services independently `deployable` and `evolvable`.

**Web Services**

When HTTP is used as the underlying protocol for talking to the service, it is called a `web service`.

Example:

```markdown
1. A client application running on a user’s device (e.g., a native app on a mobile device, or JavaScript web app using Ajax) making requests to a service over HTTP. These requests typically go over the public internet.
2. One service making requests to another service owned by the same organization, often located within the same datacenter, as part of a service-oriented/microservices architecture. (Software that supports this kind of use case is sometimes called middleware.)
3. One service making requests to a service owned by a different organization, usually via the internet. This is used for data exchange between different organizations’ backend systems. This category includes public APIs provided by online services, such as credit card processing systems, or OAuth for shared access to user data.
```

There are two popular approaches to web services: `REST` and `SOAP`.

`REST` is `not` a `protocol`, but rather a `design` philosophy that builds upon the principles of HTTP. It `emphasizes simple data formats`, `using URLs for identifying resources` and `using HTTP features for cache control, authentication, and content type negotiation`. REST has been gaining popularity compared to SOAP, at least in the context of `cross-organizational service integration`, and is often associated with `microservices`. An `API designed` according to the principles of REST is called `RESTful`.

`SOAP` is an `XML-based protocol` for making network API requests. Although it is most commonly used over HTTP, it aims to be independent from HTTP and avoids using most HTTP features. Instead, it comes with a sprawling and complex multitude of related standards (the web service framework, known as WS-*) that add various features.

The API of a `SOAP web service` is described using an `XML-based language` called the `Web Services Description Language`, or `WSDL`. WSDL enables code generation so that a client can access a remote service using local classes and method calls (which are encoded to XML messages and decoded again by the framework). This is useful in statically typed programming languages, but less so in dynamically typed ones.

**The problems with `remote procedure calls (RPCS)`**

`Remote Procedure Call(RPC)` model tries to make a `request to a remote network service` look the same as calling a function or method in your programming language, within the same process (this abstraction is called location transparency). A network request is very different from a local function call:

- A `local` function call is `predictable` and either succeeds or fails, depending only on parameters that are under your control. A `network` request is `unpredictable`: the request or response may be lost due to a network problem, or the remote machine may be slow or unavailable, and such problems are entirely outside of your control. Network problems are common, so you have to anticipate them, for example by retrying a failed request.
- A `local` function call either `returns a result`, or `throws an exception`, or `never returns` (because it goes into an infinite loop or the process crashes). A `network` request has another possible outcome: it may `return without a result`, due to a `timeout`. In that case, you simply don’t know what happened: if you don’t get a response from the remote service, you have no way of knowing whether the request got through or not.
- If you `retry` a `failed network request`, it could happen that the previous request actually got through, and only the response was lost. In that case, retrying will cause the action to be `performed multiple times`, unless you build a mechanism for deduplication (idempotence) into the protocol. `Local` function calls `don’t have` this problem.
- Every time you call a `local` function, it normally takes about the `same time to execute`. A `network` request is much `slower` than a function call, and `its latency` is also wildly variable: at good times it may complete in less than a millisecond, but when the network is congested or the remote service is overloaded it may take many seconds to do exactly the same thing.
- When you `call` a `local` function, you can efficiently `pass it references (pointers)` to objects in `local` memory. When you make a `network` request, all those parameters need to be `encoded into a sequence of bytes` that can be sent over the network. That’s okay if the parameters are primitives like numbers or strings, but quickly becomes problematic with larger objects.
- The client and the service may be implemented in different programming languages, so the `RPC framework must translate datatypes` from one language into another. This can end up ugly, since not all languages have the same types—recall JavaScript’s problems with numbers greater than 253, for example (see “JSON, XML, and Binary Variants”). This problem doesn’t exist in a single process written in a single language.

**Current Directions for RPC**

`Custom RPC` protocols `with` a `binary encoding` format can achieve better performance than something generic like JSON over REST. However, a `RESTful API` has other significant `advantages`: `it is good for experimentation and debugging` (you can simply make requests to it using a web browser or the command-line tool curl, without any code generation or software installation), `it is supported by all mainstream programming languages and platforms, and there is a vast ecosystem of tools available` (servers, caches, load balancers, proxies, firewalls, monitoring, debugging tools, testing tools, etc.).

**Data Encoding And Evolution for RPC**

It is reasonable to assume that all the `servers will be updated first, and all the clients second`. Thus, you only need backward compatibility on requests, and forward compatibility on responses.

The backward and forward compatibility properties of an RPC scheme are inherited from whatever encoding it uses:

- Thrift, gRPC (Protocol Buffers), and Avro RPC can be evolved according to the compatibility rules of the respective encoding format.
- In SOAP, requests and responses are specified with XML schemas. These can be evolved, but there are some subtle pitfalls.
- RESTful APIs most commonly use JSON (without a formally specified schema) for responses, and JSON or URI-encoded/form-encoded request parameters for requests. Adding optional request parameters and adding new fields to response objects are usually considered changes that maintain compatibility.

For `RESTful` APIs, common approaches are to `use a version number in the URL` or `in the HTTP Accept header`. For services that `use API keys to identify a particular client`, another option is to `store a client’s requested API version on the server` and to allow this version selection to be updated through a separate administrative interface.

### Message-Passing Dataflow

`Asynchronous message-passing systems` between RPC and databases. They are similar to RPC in that a client’s request (usually called a `message`) is delivered to another process with low latency. They are similar to databases in that the message is not sent via a direct network connection, but goes via an intermediary called a `message broker` (also called a `message queue` or `message-oriented middleware`), which stores the message temporarily.

Using a `message broker` has several `advantages` compared to direct RPC:

- It can act as a buffer if the recipient is unavailable or overloaded, and thus improve system reliability.
- It can automatically redeliver messages to a process that has crashed, and thus prevent messages from being lost.
- It avoids the sender needing to know the IP address and port number of the recipient (which is particularly useful in a cloud deployment where virtual machines often come and go).
- It allows one message to be sent to several recipients.
- It logically decouples the sender from the recipient (the sender just publishes messages and doesn’t care who consumes them).

`Message-passing communication` is usually `one-way`: a sender normally doesn’t expect to receive a reply to its messages. It is possible for a process to send a response, but this would usually be done on a separate channel. This communication pattern is asynchronous: the sender doesn’t wait for the message to be delivered, but simply sends it and then forgets about it.

**Message Brokers**

In general, `message brokers` are used as follows: one process sends a message to a named `queue` or `topic`, and the broker ensures that the message is delivered to one or more `consumers` of or `subscribers` to that queue or topic.

A `topic` provides only `one-way` dataflow. However, a consumer may itself publish messages to another topic, or to a reply queue that is consumed by the sender of the original message (allowing a request/response dataflow, similar to RPC).

Message brokers typically don’t enforce any particular data model—a message is just a sequence of bytes with some metadata, so you can use any encoding format. If the encoding is backward and forward compatible, you have the greatest flexibility to change publishers and consumers independently and deploy them in any order.

If a consumer republishes messages to another topic, you may need to be careful to preserve unknown fields, to prevent the issue described previously in the context of databases.

**Distributed Actor Frameworks**

The `actor model` is a programming model for `concurrency` in a `single` process. `Each actor typically represents one client or entity`, it may `have some local state` (which is not shared with any other actor), and `it communicates with other actors by sending and receiving asynchronous messages`. Message delivery is not guaranteed: in certain error scenarios, messages will be lost. Since each actor processes only one message at a time, it doesn’t need to worry about threads, and each actor can be scheduled independently by the framework.

In `distributed actor` frameworks, this programming model is used to `scale an application across multiple nodes`. The same message-passing mechanism is used, no matter whether the sender and recipient are on the same node or different nodes. If they are on different nodes, the message is transparently encoded into a byte sequence, sent over the network, and decoded on the other side.

Three popular distributed actor frameworks handle message encoding as follows:

- `Akka` uses Java’s built-in serialization by default, which does not provide forward or backward compatibility. However, you can replace it with something like Protocol Buffers, and thus gain the ability to do rolling upgrades.
- `Orleans` supports rolling upgrades using its own versioning mechanism. It allows new actor methods to be defined (that is, new types of incoming message that an actor can process) while maintaining backward compatibility, provided that existing methods are not changed.
- In `Erlang OTP` it is surprisingly hard to make changes to record schemas (despite the system having many features designed for high availability); rolling upgrades are possible but need to be planned carefully. An experimental new maps datatype (a JSON-like structure, introduced in Erlang R17 in 2014) may make this easier in the future.

## Summary

Many services need to support `rolling upgrades`, where a new version of a service is gradually deployed to a few nodes at a time, rather than deploying to all nodes simultaneously. Rolling upgrades allow new versions of a service to be released without downtime (thus encouraging frequent small releases over rare big releases) and make deployments less risky (allowing faulty releases to be detected and rolled back before they affect a large number of users). These properties are hugely beneficial for `evolvability`, the ease of making changes to an application.

All data flowing around the system is encoded in a way that provides `backward compatibility` (new code can read old data) and `forward compatibility` (old code can read new data).

We discussed several data encoding formats and their compatibility properties:

- `Programming language–specific encodings` are `restricted` to a `single programming language` and often `fail to provide forward and backward compatibility`.
- `Textual formats` like JSON, XML, and CSV are widespread, and their compatibility depends on how you use them. They have `optional schema languages`, which are sometimes helpful and sometimes a hindrance. These formats are somewhat vague about `datatypes`, so you have to `be careful with things like numbers and binary strings`.
- `Binary schema–driven formats` like Thrift, Protocol Buffers, and Avro `allow compact, efficient encodin`g with clearly defined forward and backward compatibility semantics. The schemas can be `useful` for `documentation and code generation in statically typed languages`. However, these formats have the `downside that data needs to be decoded before it is human-readable`.

We also discussed several modes of dataflow, illustrating different scenarios in which data encodings are important:

- `Databases`, where the process writing to the database encodes the data and the process reading from the database decodes it
- `RPC and REST APIs`, where the client encodes a request, the server decodes the request and encodes a response, and the client finally decodes the response
- `Asynchronous message passing` (using `message brokers` or `actors`), where nodes communicate by sending each other messages that are encoded by the sender and decoded by the recipient

#### Reference

<https://www.amazon.com/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321>