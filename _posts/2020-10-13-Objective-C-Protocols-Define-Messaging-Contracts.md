---
layout: post
title: Objective-C - Protocols Define Messaging Contracts
date: 2020-10-13 22:31:00
comment_id: 103
categories: [Objective-C]
tags: [protocol, delegate]
---

# Working with Protocols

Objective-C is available for defining `protocols` which declare method used for specific case.

## Protocols Define Messaging Contacts

> A class interface declares the methods and properties associated with that class. A protocol, by contrast, is used to declare methods and properties that are independent of any specific class.
>
> Protocols can include declarations for both instance methods and class methods, as well as properties.

```objective-c
/* Protocol */
@protocol ProtocolName
// list of methods and properties
@end

// ------ Sample ------
@protocol XYZPieChartViewDataSource
- (NSUInteger)numberOfSegments;
- (CGFloat)sizeOfSegmentAtIndex:(NSUInteger)segmentIndex;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segmentIndex;
@end

// syntax to declare the data source property for the view
@interface XYZPieChartView : UIView
@property (weak) id <XYZPieChartViewDataSource> dataSource;
...
@end
```

Protocols can also have optional methods. The default methods declared in protocol are required methods. We could mark protocol methods as optional using `@optional` directive:

> The @optional directive applies to any methods that follow it, either until the end of the protocol definition, or until another directive is encountered, such as @required. 

```objective-c
// This example defines a protocol with three required methods and two optional methods.
@protocol XYZPieChartViewDataSource
- (NSUInteger)numberOfSegments;
- (CGFloat)sizeOfSegmentAtIndex:(NSUInteger)segmentIndex;
@optional
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segmentIndex;
- (BOOL)shouldExplodeSegmentAtIndex:(NSUInteger)segmentIndex;
@required
- (UIColor *)colorForSegmentAtIndex:(NSUInteger)segmentIndex;
@end

// check `optional` methods exist or not before using it
// use a `@selector()` to identify the method.
NSString *thisSegmentTitle;
if ([self.dataSource respondsToSelector:@selector(titleForSegmentAtIndex:)]) {
	thisSegmentTitle = [self.dataSource titleForSegmentAtIndex:index];
}
```

Protocols can also inherit from other protocols.

```objective-c
// any object that adopts MyProtocol also effectively adopts all the methods declared in the NSObject protocol.
@protocol MyProtocol <NSObject>
...
@end
```

## Conforming to Protocols

```objective-c
// class adopt a protocol
@interface MyClass : NSObject <MyProtocol>
...
@end

// class adopt multiple protocols
@interface MyClass : NSObject <MyProtocol, AnotherProtocol, YetAnotherProtocol>
...
@end
```

> Once you’ve indicated conformance to a protocol, the class must at least provide method implementations for each of the required protocol methods, as well as any optional methods you choose. The compiler will warn you if you fail to implement any of the required methods.
>
> The method declaration in a protocol is just like any other declaration. The method name and argument types in the implementation must match the declaration in the protocol.

## Protocols Are Used for Anonymity

> Protocols are also useful in situations where the class of an object isn’t known, or needs to stay hidden.

```objective-c
// As an example, the developer of a framework may choose not to 
// publish the interface for one of the classes within the framework. 
// Because the class name isn’t known, it’s not possible for a user 
// of the framework to create an instance of that class directly. 
// Instead, some other object in the framework would typically be 
// designated to return a ready-made instance
id utility = [frameworkObject anonymousUtility];

// publish a protocol, class stays anonymous, object can still be used in limited way
id <XYZFrameworkUtility> utility = [frameworkObject anonymousUtility];

// example: NSFetchedResultsController class
// If you’re working with a table view whose content is split into 
// multiple sections, you can also ask a fetched results controller for 
// the relevant section information. Rather than returning a specific 
// class containing this section information, the 
// NSFetchedResultsController class instead returns an anonymous object, 
// which conforms to the NSFetchedResultsSectionInfo protocol. 
NSInteger sectionNumber = ...
id <NSFetchedResultsSectionInfo> sectionInfo =
		[self.fetchedResultsController.sections objectAtIndex:sectionNumber];
NSInteger numberOfRowsInSection = [sectionInfo numberOfObjects];
```

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html#//apple_ref/doc/uid/TP40011210-CH11-SW1>
