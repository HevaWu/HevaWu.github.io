---
layout: post
title: SQL vs NoSQL
date: 2020-03-28 16:22:00
comment_id: 70
categories: [Database, System Design]
tags: [SQL, NoSQL]
---

- SQL: relational database
- NoSQL: non-relational database

`Relational` database is a viable option most times, it is `unsuited` for `large` datasets and big data analysis.

## Language

`SQL` manipulate the data based on SQL which is one of the most `versatile` and `widely-used language` options available. While this makes it a safe choice especially for complex queries, it can also be restrictive. This is because it `requires the use of predefined schemas to determine the structure of data` before you work with it and changing the structure can be quite confusing

`NoSQL` database which has a `dynamic` schema for `unstructured` data. In here, data is `stored in many ways` which means it can be `document-oriented`, c`olumn-oriented`, `graph-based`, etc. This flexibility means that documents can be created without having a defined structure and so `each document can have its own unique structure`.

## Scalability

`SQL` databases are `vertically` scalable. This means that the l`oad on a single server can be increased` by increasing things like `RAM`, `CPU` or `SSD`. (More floors can be added to this building).

`NoSQL` databases are `horizontally` scalable. This means that more traffic can be handled by `sharding`, or `adding more servers` in your NoSQL database.

`NoSQL` can ultimately become `larger` and more powerful, making NoSQL databases the preferred choice for large or ever-changing data sets.

## Property followed

`SQL` databases follow `ACID` properties (Atomicity, Consistency, Isolation and Durability).
`NoSQL` database follows the `Brewers CAP` theorem (Consistency, Availability and Partition tolerance).

## Schema Design

A schema refers to the blueprint of a database i.e how the data is organized.

The poor database admins couldn’t find a table in `NoSQL` because there is `no standard schema definition` for NoSQL databases. They are either `key-value` pairs, `document-based`, `graph databases` or `wide-column` stores depending on the requirements. `NoSQL` databases are much better suited for `big data` as `flexibility` is an important requirement which is fulfilled by their `dynamic` schema.

If those database admins had gone to a `SQL` bar, they certainly would have found `tables` as SQL databases `have a table-based schema`. This difference in schema makes relational SQL databases a better option for applications that `require multi-row transactions` such as an accounting system or for legacy systems that were built for a relational structure.

## Community

`SQL` is a `mature` technology and there are many `experienced` developers who understand it. Also, `great support is available` for all SQL databases from their vendors. There are even a lot of independent consultants who can help with the SQL database for very large scale deployments.

On the other hand, `NoSQL` is comparatively `new` and so some NoSQL databases are `reliant on community support`. Also, only limited outside experts are available for setting up and deploying large scale NoSQL deployments.

## Q&A

### Is NoSQL faster than SQL?

In general, `NoSQL` is `not faster` than `SQL` just as `SQL` is `not faster` than `NoSQL`. For those that didn’t get that statement, it means that speed as a factor for SQL and NoSQL databases depends on the context.

`SQL` databases are `normalized` databases where the `data is broken down into various logical tables to avoid data redundancy and data duplication`. In this scenario, SQL databases are `faster` than their NoSQL counterparts for `joins, queries, updates`, etc.

On the other hand, `NoSQL` databases are specifically `designed` for `unstructured` data which can be `document-oriented`, `column-oriented`, `graph-based`, etc. In this case, a particular `data entity is stored together and not partitioned`. So performing `read` or `write` operations `on a single data entity` is `faster` for `NoSQL` databases as compared to SQL databases.

### Is NoSQL better for Big Data Applications?

The `NoSQL` databases for `big data` were specifically developed by the top internet companies such as Google, Yahoo, Amazon, etc. as the existing relational databases were not able to cope with the increasing data processing requirements.

`NoSQL` databases have a `dynamic` schema that is much `better` suited for `big data` as `flexibility` is an important requirement. Also, large amounts of analytical data can be stored in `NoSQL` databases for `predictive analysis`. An example of this is data from various social media sites such as Instagram, Twitter, Facebook, etc. NoSQL databases are `horizontally` scalable and can `ultimately become larger and more powerful` if required. All of this makes NoSQL databases the preferred choice for big data applications.

#### Reference

<https://www.geeksforgeeks.org/sql-vs-nosql-which-one-is-better-to-use/>