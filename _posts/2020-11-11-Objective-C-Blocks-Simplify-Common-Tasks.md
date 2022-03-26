---
layout: post
title: Objective-C - Blocks Simplify Common Tasks
date: 2020-11-11 21:48:00
comment_id: 109
categories: [Objective-C]
tags: [Block]
---

# Working with Blocks

> Blocks are often used to simplify common tasks such as collection enumeration, sorting and testing. They also make it easy to schedule tasks for concurrent or asynchronous execution using technologies like Grand Central Dispatch (GCD).

Blocks defines the objects to combine data.

## Block Syntax

```objective-c
/* Define: use caret symbol(^) */
^{
	NSLog(@"This is a block");
}

void (^simpleBlock)(void);

simpleBlock = ^{
	NSLog(@"This is a block");
};

void (^simpleBlock)(void) = ^{
	NSLog(@"This is a block");
};

// call block
simpleBlock();
```

### Block: Arguments and return values

```objective-c
/* Block: Arguments and return values */

double (^multiplyTwoValues)(double, double);

^ (double firstValue, double secondValue) {
	return firstValue * secondValue;
}

double (^multiplyTwoValues)(double, double) =
							^(double firstValue, double secondValue) {
								return firstValue * secondValue;
							};

double result = multiplyTwoValues(2,4);

NSLog(@"The result is %f", result);
```

### Block: Capture values from enclosing scope

```objective-c
/* Block: Capture values from enclosing scope */

- (void)testMethod {
    int anInteger = 42;
 
    void (^testBlock)(void) = ^{
        NSLog(@"Integer is: %i", anInteger);
    };
 
    testBlock();
}
```

Value will be captured when block is defined.

```objective-c
int anInteger = 42;
 
void (^testBlock)(void) = ^{
	NSLog(@"Integer is: %i", anInteger);
};

anInteger = 84;

testBlock();

// Result
// the value captured by the block is unaffected

Integer is: 42
```

### __block  to Share Storage

Use `__block` storage type modifier to change value of the captured variable from a block.

```objective-c
__block int anInteger = 42;
 
void (^testBlock)(void) = ^{
	NSLog(@"Integer is: %i", anInteger);
};

anInteger = 84;

testBlock();

// Result
// anInteger is declared as a __block variable, 
// its storage is shared with the block declaration

Integer is: 84

// block can modify original value now

__block int anInteger = 42;
 
void (^testBlock)(void) = ^{
	NSLog(@"Integer is: %i", anInteger);
	anInteger = 100;
};

testBlock();
NSLog(@"Value of original variable is now: %i", anInteger);

// Result

Integer is: 42
Value of original variable is now: 100
```

### Pass Blocks as Arguments to Methods or Functions

> In practice, it’s common to pass blocks to functions or methods for invocation elsewhere. You might use Grand Central Dispatch to invoke a block in the background, for example, or define a block to represent a task to be invoked repeatedly, such as when enumerating a collection.
>
> Blocks are also used for callbacks, defining the code to be executed when a task completes.

```objective-c
// ------ Sample ------
- (void)beginTaskWithCallbackBlock:(void (^)(void))callbackBlock;
- (void)beginTaskWithCallbackBlock:(void (^)(void))callbackBlock {
    ...
    callbackBlock();
}

- (IBAction)fetchRemoteInformation:(id)sender {
	[self showProgressIndicator];

	XYZWebTask *task = ...

	[task beginTaskWithCallbackBlock:^{
		[self hideProgressIndicator];
	}];
}

// this callback block captures self in order to be able to 
// call the hideProgressIndicator method when invoked. It’s 
// important to take care when capturing self because it’s easy 
// to create a strong reference cycle
```

### Block should always be the last argument to a method

```objective-c
// ------ Sample ------
- (void)beginTaskWithName:(NSString *)name completion:(void(^)(void))callback;

[self beginTaskWithName:@"MyTask" completion:^{
	NSLog(@"The task is complete");
}];
```

### Use Type Definitions to simplify block syntax

```objective-c
typedef void (^XYZSimpleBlock)(void);

XYZSimpleBlock anotherBlock = ^{
	...
};

- (void)beginFetchWithCallbackBlock:(XYZSimpleBlock)callbackBlock {
    ...
    callbackBlock();
}
```

### Objects with Blocks Properties

```objective-c
@interface XYZObject : NSObject
@property (copy) void (^blockProperty)(void);
@end

// specify copy as the property attribute, because a block 
// needs to be copied to keep track of its captured state 
// outside of the original scope. 

// set
self.blockProperty = ^{
	...
};
// invoke
self.blockProperty();

// use type definitions

typedef void (^XYZSimpleBlock)(void);
 
@interface XYZObject : NSObject
@property (copy) XYZSimpleBlock blockProperty;
@end

/* Avoid Strong Reference cycles */

- (void)configureBlock {
    XYZBlockKeeper * __weak weakSelf = self;
    self.block = ^{
        [weakSelf doSomething];   // capture the weak reference
                                  // to avoid the reference cycle
    }
}
```

## Blocks Can Simplify Enumeration

```objective-c
// ------ Sample ------
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
NSArray *array = ...
[array enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
	NSLog(@"Object at index %lu is %@", idx, obj);
}];

// `stop` is a pointer
[array enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
	if (...) {
		*stop = YES;
	}
}];

/* Use NSEnumerationConcurrent option 
This flag indicates that the enumeration block invocations may 
be distributed across multiple threads, offering a potential 
performance increase if the block code is particularly 
processor intensive. Note that the enumeration order is 
undefined when using this option.
*/

[array enumerateObjectsWithOptions:NSEnumerationConcurrent
						usingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
	...
}];
```

## Blocks Can Simplify Concurrent Tasks

### Block in Operation Queues

```objective-c
/* Use NSBlockOperation to create an operation using a block
*/
NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
    ...
}];

// schedule task on main queue:
NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
[mainQueue addOperation:operation];
 
// schedule task on background queue:
NSOperationQueue *queue = [[NSOperationQueue alloc] init];
[queue addOperation:operation];
```

### Block in GCD(Grand Central Dispatch)

```objective-c
// schedule a task for concurrent execution
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

// dispatch the block to the queue, you use either the 
// dispatch_async() or dispatch_sync() functions
dispatch_async(queue, ^{
    NSLog(@"Block for asynchronous execution");
});
```

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html#//apple_ref/doc/uid/TP40011210-CH8-SW1>
