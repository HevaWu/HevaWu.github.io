---
layout: post
title: Objective-C - An App Is Built from a Network of Objects
date: 2020-10-12 22:13:00
comment_id: 101
categories: [Objective-C]
tags: [class, object, encapsulate]
---

There are so many iOS coding languages, and of course Objective-C is one of the major one. Though recently engineers prefer Swift, but I think we should also be familiar with Objective-C which could help understanding some basic implementation knowledge. I've known Apple have ⬇️ guide, but I didn't look through it in detail. So I'd like to memo thing at here.

<https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011210-CH1-SW1>

> Objective-C is the primary programming language you use when writing software for OS X and iOS. It’s a superset of the C programming language and provides object-oriented capabilities and a dynamic runtime. Objective-C inherits the syntax, primitive types, and flow control statements of C and adds syntax for defining classes and methods. It also adds language-level support for object graph management and object literals while providing dynamic typing and binding, deferring many responsibilities until runtime.

The introduction site divide the guide in several parts. I will go through them one by one.

- An App Is Built from a Network of Objects
- Categories Extend Existing Classes
- Protocols Define Messaging Contracts
- Values and Collections Are Often Represented as Objective-C Objects
- Blocks Simplify Common Tasks
- Error Objects Are Used for Runtime Problems
- Objective-C Code Follows Established Conventions

This article will focus on the `An App Is Built from a Network of Objects`, the later parts will be put in the later articles 😆

# An App Is Built from a Network of Objects

> When you write software for OS X or iOS, most of your time is spent working with objects. Objects in Objective-C are just like objects in other object-oriented programming languages: they package data with related behavior.

## Defining Classes

> In object-oriented programming terms, an object is an instance of a class. 

In objective-C, we could define a class by

- interface
  - describes the way we intend the class and its instances to be used
  - includes the list of messages the class can receive
- class implementation
  - contains the code to be executed in response to each message

### Class Inherit

> In the world of object-oriented programming, objects are also categorized into hierarchical groups. Rather than using distinct terms for the different hierarchical levels such as genus or species, objects are simply organized into classes.
>
> When one class inherits from another, the child inherits all the behavior and properties defined by the parent. It also has the opportunity either to define its own additional behavior and properties, or override the behavior of the parent.

### Root Class Base Functionality

> When an Objective-C object needs to work with an instance of another class, it is expected that the other class offers certain basic characteristics and behavior. For this reason, Objective-C defines a root class from which the vast majority of other classes inherit, called `NSObject`.
>
> When you’re defining your own classes, you should at a minimum inherit from `NSObject`. In general, you should find a Cocoa or Cocoa Touch object that offers the closest functionality to what you need and inherit from that.

### Interface -- Define Expected Interactions

The interface of the class defines the way we intend other objects to interact. Normally, the public interface will be separate with the class implementation, where include the internal basic behavior.

> In Objective-C, the interface and implementation are usually placed in separate files so that you only need to make the interface public.

```objective-c
// declare class interface
@interface SimpleClass : NSObject
 
@end

// ------ Sample ------

@interface Person : NSObject

// Property Attributes Indicate Data Accessibility and Storage Considerations
@property (readonly) NSString *firstName;
@property (readonly) NSString *lastName;

// Method Declarations Indicate the Messages an Object Can Receive
- (void)someMethodWithValue:(SomeType)value;
- (void)someMethodWithFirstValue:(SomeType)value1 secondValue:(AnotherType)value2;

@end
```

### Implementation -- Provide Internal Behavior

> The interface for a class is usually placed inside a dedicated file, often referred to as a `header` file, which generally has the filename extension `.h`. You write the implementation for an Objective-C class inside a source code file with the extension `.m`.

```objective-c
#import "XYZPerson.h"
 
@implementation XYZPerson
 
@end

// ------ Sample ------
// If class interface is like:
// @interface XYZPerson : NSObject
// - (void)sayHello;
// @end

#import "XYZPerson.h"
 
@implementation XYZPerson
- (void)sayHello {
    NSLog(@"Hello, World!");
}
@end

```

### Objective-C Classes Are also Objects

> In Objective-C, a class is itself an object with an opaque type called Class. Classes can’t have properties defined using the declaration syntax shown earlier for instances, but they can receive messages.
>
> The typical use for a class method is as a factory method, which is an alternative to the object allocation and initialization procedure.
>
> Class methods are denoted by the use of a `+` sign, which differentiates them from instance methods using a `-` sign.
>
> Class method prototypes may be included in a class interface, just like instance method prototypes. Class methods are implemented in the same way as instance methods, inside the `@implementation` block for the class.

## Working with Objects

> Before an object can be used, it must be created properly using a combination of memory allocation for its properties and any necessary initialization of its internal values.

### Object Send and Receive Messages

```objective-c
// basic send messages between objects
[someObject doSomething];

// ------ Sample ------
[somePerson sayHello];
```

![](/images/2020-10-12-Objective-C-An-App-Is-Built-from-a-Network-of-Objects/programflow1.png#simulator)

> Objective-C objects, by contrast, are allocated slightly differently. Objects normally have a longer life than the simple scope of a method call. In particular, an object often needs to stay alive longer than the original variable that was created to keep track of it, so an object’s memory is allocated and deallocated dynamically.

```objective-c
// pass objects for method parameters
- (void)someMethodWithValue:(SomeType)value;

// ------ Sample ------
- (void)saySomething:(NSString *)greeting {
    NSLog(@"%@", greeting);
}

// method can return values
- (int)magicNumber;

// ------ Sample ------
- (int)magicNumber {
    return 42;
}

[someObject magicNumber]; // this is fine
int interestingNumber = [someObject magicNumber]; // If you do need to keep track of the returned value

// the string object continues to exist when it is passed as a return value even though the stringToReturn pointer goes out of scope.
- (NSString *)magicString {
    NSString *stringToReturn = // create an interesting string...
 
    return stringToReturn;
}
```

>  There are some memory management considerations in this situation: a returned object (created on the heap) needs to exist long enough for it to be used by the original caller of the method, but not in perpetuity because that would create a memory leak. For the most part, the Automatic Reference Counting (ARC) feature of the Objective-C compiler takes care of these considerations for you.

![](/images/2020-10-12-Objective-C-An-App-Is-Built-from-a-Network-of-Objects/programflow4.png#simulator)

### Objects Are Created Dynamically

> Memory is allocated dynamically for an Objective-C object. The first step in creating an object is to make sure enough memory is allocated not only for the properties defined by an object’s class, but also the properties defined on each of the superclasses in its inheritance chain.

```objective-c
// The NSObject root class provides a class method, alloc, which handles this process for you:
// 
// Notice that the return type of this method is id. This is a special keyword used in Objective-C to mean “some kind of object.” It is a pointer to an object, like (NSObject *), but is special in that it doesn’t use an asterisk.
//
// The alloc method has one other important task, which is to clear out the memory allocated for the object’s properties by setting them to zero. This avoids the usual problem of memory containing garbage from whatever was stored before, but is not enough to initialize an object completely.
+ (id)alloc;

// You need to combine a call to alloc with a call to init, another NSObject method:
- (id)init;

// NSObject *newObject = [[NSObject alloc] init];

// use new to Create an object If No Arguments Are Needed for Initialization
XYZObject *object = [XYZObject new];
// is effectively the same as:
XYZObject *object = [[XYZObject alloc] init];

// literals
NSString *someString = @"Hello, World!";
// equal to 
NSString *someString = [NSString stringWithCString:"Hello, World!" encoding:NSUTF8StringEncoding];
```

### Objective-C is a Dynamic Language

> The id type defines a generic object pointer. It’s possible to use id when declaring a variable, but you lose compile-time information about the object.

```objective-c
id someObject = @"Hello, World!";
[someObject removeAllObjects];
// In this case, someObject will point to an NSString instance, but the compiler knows nothing about that instance beyond the fact that it’s some kind of object. The removeAllObjects message is defined by some Cocoa or Cocoa Touch objects (such as NSMutableArray) so the compiler doesn’t complain, even though this code would generate an exception at runtime because an NSString object can’t respond to removeAllObjects.

// rewrite to static type
NSString *someObject = @"Hello, World!";
[someObject removeAllObjects];

/* ----- equality of objects ----- */

// 2 pointers are pointing to same object or not
if (firstPerson == secondPerson) {
	// firstPerson is the same object as secondPerson
}

// 2 objects represent same data or not
if ([firstPerson isEqual:secondPerson]) {
	// firstPerson is identical to secondPerson
}

// one object represents a greater or lesser value than another
if ([someDate compare:anotherDate] == NSOrderedAscending) {
	// someDate is earlier than anotherDate
}

/* ----- nil of objects ----- */

// somePerson is automatically set to nil
XYZPerson *somePerson;

// check if object is not nil
if (somePerson != nil) {
	// somePerson points to an object
}
// OR
if (somePerson) {
	// somePerson points to an object
}

// check if object is nil
if (somePerson == nil) {
	// somePerson does not point to an object
}
// OR
if (!somePerson) {
	// somePerson does not point to an object
}
```

## Encapsulating Data

> If an object needs to maintain a link to another object through a property, it’s important to consider the nature of the relationship between the two objects. Although memory management for Objective-C objects is mostly handled for you through Automatic Reference Counting (ARC), it’s important to know how to avoid problems like strong reference cycles, which lead to memory leaks.

### Properties Encapsulate an Object's Values

```objective-c
/* declare public properties for exposed data */

@interface XYZPerson : NSObject
@property NSString *firstName;
@property NSString *lastName;
@end
```

Naming conventions of synthesized method:

- The method used to access the value (the `getter` method) has the same name as the property. The getter method for a property called `firstName` will also be called `firstName`.
- The method used to set the value (the setter method) starts with the word “set” and then uses the capitalized property name. The setter method for a property called `firstName` will be called `setFirstName:`.

> In general, property accessor methods should be [Key-Value Coding (KVC)](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueCoding/index.html#//apple_ref/doc/uid/10000107i) compliant, which means that they follow explicit naming conventions.

```objective-c
/* use accessor methods to get/set propertyValues */

NSString *firstName = [somePerson firstName];
[somePerson setFirstName:@"Johnny"];

// attribute
@property (readonly) NSString *fullName;
// The opposite of `readonly` is `readwrite`. There’s no need to specify the `readwrite` attribute explicitly, because it is the default.

// it’s possible to specify a custom name by adding attributes to the property. 
@property (getter=isFinished) BOOL finished;
// specify multiple attributes, 
@property (readonly, getter=isFinished) BOOL finished;
// In this case, the compiler will synthesize only an isFinished method, but not a setFinished: method.

/* Dot Syntax  */

NSString *firstName = somePerson.firstName;
// Getting a value using somePerson.firstName is the same as using [somePerson firstName]

somePerson.firstName = @"Johnny";
// Setting a value using somePerson.firstName = @"Johnny" is the same as using [somePerson setFirstName:@"Johnny"]
```

> By default, a `readwrite` property will be backed by an instance variable, which will again be synthesized automatically by the compiler.
>
> An instance variable is a variable that exists and holds its value for the life of the object. The memory used for instance variables is allocated when the object is first created (through alloc), and freed when the object is `deallocated`.
>
> Unless you specify otherwise, the synthesized instance variable has the same name as the property, but with an underscore prefix. For a property called `firstName`, for example, the synthesized instance variable will be called `_firstName`.

```objective-c
/* Backed by instance variables */

// myString is a local variable and _someString is an instance variable
- (void)someMethod {
    NSString *myString = @"An interesting string";
 
    _someString = myString;
}

// use accessor methods or dot syntax for property access even if you’re accessing an object’s properties from within its own implementation, in which case you should use self
- (void)someMethod {
    NSString *myString = @"An interesting string";
 
    self.someString = myString;
  // or
    [self setSomeString:myString];
}

/* Customize synthesized instance variable names */

@implementation YourClass
@synthesize propertyName = instanceVariableName;
...
@end

// ------ Sample ------

@synthesize firstName = ivar_firstName;

// If you use @synthesize without specifying an instance variable name, the instance variable will bear the same name as the property.

@synthesize firstName;
// In this example, the instance variable will also be called firstName, without an underscore.

/* Define Instance Variables without Properties */

@interface SomeClass : NSObject {
    NSString *_myNonPropertyInstanceVariable;
}
...
@end
 
@implementation SomeClass {
    NSString *_anotherCustomInstanceVariable;
}
...
@end
```

> You should always access the instance variables directly from within an initialization method because at the time a property is set, the rest of the object may not yet be completely initialized. Even if you don’t provide custom accessor methods or know of any side effects from within your own class, a future subclass may very well override the behavior.

```objective-c
/* Access Instance Variables Directly from Initializer Methods */

- (id)init {
    self = [super init];
 
    if (self) {
        // initialize instance variables here
    }
 
    return self;
}
```

![](/images/2020-10-12-Objective-C-An-App-Is-Built-from-a-Network-of-Objects/initflow.png#simulator)

```objective-c
/* Custom Accessor Methods */

@property (readonly) NSString *fullName;

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

// custom accessor method
//
// If you need to write a custom accessor method for a property that does use an instance variable, you must access that instance variable directly from within the method
- (XYZObject *)someImportantObject {
    if (!_someImportantObject) {
        _someImportantObject = [[XYZObject alloc] init];
    }
 
    return _someImportantObject;
}
```

> By default, an Objective-C property is atomic:
>
> This means that the synthesized accessors ensure that a value is always fully retrieved by the getter method or fully set via the setter method, even if the accessors are called simultaneously from different threads.
>
> Because the internal implementation and synchronization of atomic accessor methods is private, it’s not possible to combine a synthesized accessor with an accessor method that you implement yourself.
>
> You can use the nonatomic property attribute to specify that synthesized accessors simply set or return a value directly, with no guarantees about what happens if that same value is accessed simultaneously from different threads. For this reason, it’s faster to access a nonatomic property than an atomic one, and it’s fine to combine a synthesized setter

```objective-c
/* Properties Are Atomic by Default */

@interface XYZObject : NSObject
@property NSObject *implicitAtomicObject;          // atomic by default
@property (atomic) NSObject *explicitAtomicObject; // explicitly marked atomic
@end

// nonatomic

@interface XYZObject : NSObject
@property (nonatomic) NSObject *nonatomicObject;
@end

@implementation XYZObject
- (NSObject *)nonatomicObject {
    return _nonatomicObject;
}
// setter will be synthesized automatically
@end
```

### Manage the Object Graph through Ownership and Responsibility

> By default, both Objective-C properties and variables maintain strong references to their objects. This is fine for many situations, but it does cause a potential problem with strong reference cycles.
>
> ### Avoid Strong Reference Cycles:
> 
> Although strong references work well for one-way relationships between objects, you need to be careful when working with groups of interconnected objects. If a group of objects is connected by a circle of strong relationships, they keep each other alive even if there are no strong references from outside the group.

```objective-c
/* Use Strong and Weak Declarations to Manage Ownership */

@property (weak) id delegate;

// If you don’t want a variable to maintain a strong reference, you can declare it as __weak:
NSObject * __weak weakVariable;

// if you need to make sure a weak property is not nil before using it. It’s not enough just to test it
if (self.someWeakProperty) {
	[someObject doSomethingImportantWith:self.someWeakProperty];
}

// ------ Sample ------

NSObject *cachedObject = self.someWeakProperty;           // 1
if (cachedObject) {                                       // 2
	[someObject doSomethingImportantWith:cachedObject];   // 3
}                                                         // 4
cachedObject = nil;                                       // 5
```

> There are a few classes in Cocoa and Cocoa Touch that don’t yet support weak references, which means you can’t declare a weak property or weak local variable to keep track of them.
> 
> If you need to use a weak reference to one of these classes, you must use an unsafe reference. For a property, this means using the unsafe_unretained attribute:
>
> An unsafe reference is similar to a weak reference in that it doesn’t keep its related object alive, but it won’t be set to nil if the destination object is deallocated. This means that you’ll be left with a dangling pointer to the memory originally occupied by the now deallocated object, hence the term “unsafe.” Sending a message to a dangling pointer will result in a crash.

```objective-c
/* Unsafe Unretained References */
@property (unsafe_unretained) NSObject *unsafeProperty;
NSObject * __unsafe_unretained unsafeReference;
```

> The copy attribute means that the property will use a strong reference, because it must hold on to the new object it creates.
>
> Any object that you wish to set for a copy property must support NSCopying, which means that it should conform to the NSCopying protocol.

```objective-c
/* Copy Properties Maintain Their Own Copies */

@interface XYZBadgeView : NSView
@property (copy) NSString *firstName;
@property (copy) NSString *lastName;
@end

// set copy property's instance variable directly
- (id)initWithSomeOriginalString:(NSString *)aString {
    self = [super init];
    if (self) {
        _instanceVariableForCopyProperty = [aString copy];
    }
    return self;
}
```

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011210-CH1-SW1>
- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/DefiningClasses/DefiningClasses.html#//apple_ref/doc/uid/TP40011210-CH3-SW1>
- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithObjects/WorkingwithObjects.html#//apple_ref/doc/uid/TP40011210-CH4-SW1>
- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/EncapsulatingData/EncapsulatingData.html#//apple_ref/doc/uid/TP40011210-CH5-SW1>
