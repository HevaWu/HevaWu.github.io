---
layout: post
title: Objective-C - Values and Collections Are Often Represented as Objective-C Objects
date: 2020-10-20 21:18:00
comment_id: 104
categories: [Objective-C]
tags: [object, collection, value]
---

# Values and Collections

> Although Objective-C is an object-oriented programming language, it is a superset of C, which means you can use any of the standard C scalar (non-object) types like int, float and char in Objective-C code. There are also additional scalar types available in Cocoa and Cocoa Touch applications, such as NSInteger, NSUInteger and CGFloat, which have different definitions depending on the target architecture.

## Basic C Primitive Types Are Available in Objective-C

> The types, like NSInteger and NSUInteger, are defined differently depending on the target architecture. When building for a 32-bit environment (such as for iOS), they are 32-bit signed and unsigned integers respectively; when building for a 64-bit environment (such as for the modern OS X runtime) they are 64-bit signed and unsigned integers respectively.

## Objects Can Represent Primitive Values

```objective-c
/* Strings are represented by NSString/NSMutableString */

NSString *firstString = [[NSString alloc] initWithCString:"Hello World!"
                                                 encoding:NSUTF8StringEncoding];
NSString *secondString = [NSString stringWithCString:"Hello World!"
                                            encoding:NSUTF8StringEncoding];
NSString *thirdString = @"Hello World!";

NSString *name = @"John";
name = [name stringByAppendingString:@"ny"];    // returns a new string object

NSMutableString *name = [NSMutableString stringWithString:@"John"];
[name appendString:@"ny"];   // same object, but now represents "Johnny"

// format string

int magicNumber = ...
NSString *magicString = [NSString stringWithFormat:@"The magic number is %i", magicNumber];

/* Numbers are represented by NSNumber 
Note: NSNumber is actually a class cluster. This means that when you create an instance at runtime, you’ll get a suitable concrete subclass to hold the provided value. Just treat the created object as an instance of NSNumber.
*/

NSNumber *magicNumber = [[NSNumber alloc] initWithInt:42];
NSNumber *unsignedNumber = [[NSNumber alloc] initWithUnsignedInt:42u];
NSNumber *longNumber = [[NSNumber alloc] initWithLong:42l];
NSNumber *boolNumber = [[NSNumber alloc] initWithBOOL:YES];
NSNumber *simpleFloat = [NSNumber numberWithFloat:3.14f];
NSNumber *betterDouble = [NSNumber numberWithDouble:3.1415926535];
NSNumber *someChar = [NSNumber numberWithChar:'T'];

// use objective-c literal syntax

NSNumber *magicNumber = @42;
NSNumber *unsignedNumber = @42u;
NSNumber *longNumber = @42l;
NSNumber *boolNumber = @YES;
NSNumber *simpleFloat = @3.14f;
NSNumber *betterDouble = @3.1415926535;
NSNumber *someChar = @'T';

/* NSValue */

struct MyIntegerFloatStruct aStruct;
aStruct.i = 42;
aStruct.f = 3.14;

// (&) is used to provide the address of aStruct for the value parameter.
NSValue *structValue = [NSValue value:&aStruct
						 witttthObjCType:@encode(MyIntegerFloatStruct)];

```

## Most Collections Are Objects

The collection class like `NSArray`, `NSSet`, `NSDictionary`, which items must be an instance of an Objective-C class.

> Rather than somehow maintaining a separate copy of each collected object, the collection classes use strong references to keep track of their contents. This means that any object that you add to a collection will be kept alive at least as long as the collection is kept alive.
>
> The basic NSArray, NSSet and NSDictionary classes are immutable, which means their contents are set at creation. Each also has a mutable subclass to allow you to add or remove objects at will.

```objective-c
/* Arrays 
The arrayWithObjects: and initWithObjects: methods both take a nil-terminated, variable number of arguments, which means that you must include nil as the last value, 
*/

+ (id)arrayWithObject:(id)anObject;
+ (id)arrayWithObjects:(id)firstObject, ...;
- (id)initWithObjects:(id)firstObject, ...;

NSArray *someArray = [NSArray arrayWithObjects:someObject, someString, someNumber, someValue, nil];

// literal syntax
// You should not terminate the list of objects with nil when using this literal syntax, and in fact nil is an invalid value
NSArray *someArray = @[firstObject, secondObject, thirdObject];

// NSMutableArray
NSMutableArray *mutableArray = [NSMutableArray array];
[mutableArray addObject:@"gamma"];
[mutableArray addObject:@"alpha"];
[mutableArray addObject:@"beta"];
[mutableArray replaceObjectAtIndex:0 withObject:@"epsilon"];

/* NSSet */

NSSet *simpleSet =[NSSet setWithObjects:@"Hello, World!", @42, aValue, anObject, nil];
// lieteral syntax
NSNumber *number = @42;
NSSet *numberSet = [NSSet setWithObjects:number, number, number, number, nil];
// numberSet only contains one object

/* NSDictionary */

 NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				someObject, @"anObject",
			@"Hello, World!", @"helloString",
						@42, @"magicNumber",
				someValue, @"aValue",
							nil];

// literal syntax
// Note that for dictionary literals, the key is specified before its object and is not nil-terminated.
NSDictionary *dictionary = @{
                  @"anObject" : someObject,
               @"helloString" : @"Hello, World!",
               @"magicNumber" : @42,
                    @"aValue" : someValue
    };

NSNumber *storedNumber = [dictionary objectForKey:@"magicNumber"];
NSNumber *storedNumber = dictionary[@"magicNumber"];

[dictionary setObject:@"another string" forKey:@"secondString"];
[dictionary removeObjectForKey:@"anObject"];

/* NSNull -> no object */

NSArray *array = @[ @"string", @42, [NSNull null] ];
```

## Use Collections to Persist Your Object Graph

Use achiver object(such as `NSKeyedArchiver`) to create an archive of the collected objects.

> The only requirement to create an archive is that each object must support the NSCoding protocol. This means that each object must know how to encode itself to an archive (by implementing the encodeWithCoder: method) and decode itself when read from an existing archive (the initWithCoder: method).

```objective-c
// write to disk
NSURL *fileURL = ...
NSArray *array = @[@"first", @"second", @"third"];

BOOL success = [array writeToURL:fileURL atomically:YES];
if (!success) {
	// an error occured...
}

// read from disk
NSURL *fileURL = ...
NSArray *array = [NSArray arrayWithContentsOfURL:fileURL];
if (!array) {
	// an error occurred...
}
```

## Use the Most Efficient Collection Enumeration Techniques

```objective-c
/* enumeration */

int count = [array count];
for (int index = 0; index < count; index++) {
	id eachObject = [array objectAtIndex:index];
	...
}

// fast enumeration
for (<Type> <variable> in <collection>) {
	...
}

for (id eachObject in array) {
	NSLog(@"Object: %@", eachObject);
}

for (NSString *eachKey in dictionary) {
	id object = dictionary[eachKey];
	NSLog(@"Object: %@ for key: %@", object, eachKey);
}

int index = 0;
for (id eachObject in array) {
	NSLog(@"Object at index %i is: %@", index, eachObject);
	index++;
}

/* NSEnumerator */

for (id eachObject in [array reverseObjectEnumerator]) {
	...
}

id eachObject;
while ( (eachObject = [enumerator nextObject]) ) {
	NSLog(@"Current object is: %@", eachObject);
}
```

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/FoundationTypesandCollections/FoundationTypesandCollections.html#//apple_ref/doc/uid/TP40011210-CH7-SW1>
