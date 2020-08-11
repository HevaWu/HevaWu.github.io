---
layout: post
title: Operational Transformation
date: 2020-08-11 22:04:00
comments: true
disqus_category_id: OperationalTransformation 
categories: [Algorithm]
tags: [OT]
---

For sharing documents to others, or editing the documents at the same time. We might need to consider this OT(Operation Transformation) things. When multiple people editing the same documents at the same time, we will need to show the edits instantaneous without network latency and not lead to divergent document states.

## How does it work?

> - `Every change to a shared document is represented as an operation`. In a text editor, this operation could be the insertion of the character ‘A’ at position 12. An operation can be applied to the current document resulting in a new document state.
>
> - To handle concurrent operations, there is a `function` (usually called transform) that takes two operations that have been applied to the same document state (but on different clients) and `computes a new operation` that can be applied after the second operation and that preserves the first operation’s intended change. Let’s make this clear with an example: User A inserts the character ‘A’ at position 12 while user B inserts ‘B’ at the beginning at the document. The concurrent operations are therefore insert(12, 'A') and insert(0, 'B'). If we would simply send B’s operation to client A and applied it there, there is no problem. But if we send A’s operation to B and apply it after B’s operation has been applied, the character ‘A’ would be inserted one character one position left from the correct position. Moreover, after these operations, A’s document state and B’s document state wouldn’t be the same. Therefore, A’s operation insert(12, 'A') has to be transformed against B’s operation to take into account that B inserted a character before position 12 producing the operation insert(13, 'A'). This new operation can be applied on client B after B’s operation.
>
> - This function can be used to `build a client-server protocol that handles collaboration between any number of clients`. This is explained in Daniel Spiewak’s excellent article [Understanding and Applying Operational Transformation](http://www.codecommit.com/blog/java/understanding-and-applying-operational-transformation).

## Operational Transformation in JavaScript

Node.JS contains a ot package where we could directly install:

```s
$ npm install ot
```

### Operation

```js
// new operation
var operation = new ot.Operation()
  .retain(11)
  .insert(" dolor");

// operation apply
operation.apply("lorem ipsum"); // => "lorem ipsum dolor"
operation.apply("lorem ipsum amet"); // throws an error
// the operation doesn’t span the whole length of the string. To ensure correctness and to prevent mistakes, the invisible cursor must be positioned at the end of the input string after the last component.

// retain
operation.retain(5).apply("lorem ipsum amet"); // => "lorem ipsum dolor amet" 
// operation now contains the components retain(11), insert(" dolor") and retain(5)

// length
"lorem ipsum amet".length; // => 16
operation.baseLength; // => 16
"lorem ipsum dolor amet".length; // => 22
operation.targetLength // => 22


//
// Transform
//

// Both users start with the same document
var str = "lorem ipsum";

// User A appends the string " dolor"
var operationA = new ot.Operation()
  .retain(11)
  .insert(" dolor");
var strA = operationA.apply(str); // "lorem ipsum dolor"

// User B deletes the string "lorem " at the beginning
var operationB = new ot.Operation()
  .delete("lorem ")
  .retain(5);
var strB = operationB.apply(str); // "ipsum";

var transformedPair = ot.Operation.transform(operationA, operationB);
var operationAPrime = transformedPair[0];
var operationBPrime = transformedPair[1];

var strABPrime = operationAPrime.apply(strB); // "ipsum dolor"
var strBAPrime = operationBPrime.apply(strA); // "ipsum dolor"

//
// Server
//

var server = new or.Server("lorem ipsum");
server.broadcast = function (operation) {
	// broadcast the operation to all connected clients including the one that operation came from
};

// when receive an operation as JSON string from one of the clients, do:
function onReceiveOperation (json) {
	var operation = ot.Operation.fromJSON(JSON.parse(json));
}

// 
// Client
//

var client = new ot.Client(0); // the client joins at revision 0

client.applyOperation = function (operation) {
  // apply the operation to the editor, e.g.
  // operation.applyToCodeMirror(cm);
};

client.sendOperation = function (operation) {
  // send the operation to the server, e.g. with ajax:
  $.ajax({
    url: '/operations',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(operation)
  });
};

function onUserChange (change) {
  var operation = client.createOperation(); // has the right revision number
  // initialize operation here with for example operation.fromCodeMirrorChange
  client.applyClient(operation);
}

function onReceiveOperation (json) {
  var operation = ot.Operation.fromJSON(JSON.parse(json));
  client.applyServer(operation);
}

```

## Visualization of OT

Here is a really nice site we could directly check: <https://operational-transformation.github.io/visualization.html>

#### Reference

<http://www.codecommit.com/blog/java/understanding-and-applying-operational-transformation>

<https://operational-transformation.github.io/index.html>

<https://operational-transformation.github.io/what-is-ot.html>

<https://operational-transformation.github.io/ot-for-javascript.html>

<https://operational-transformation.github.io/visualization.html>