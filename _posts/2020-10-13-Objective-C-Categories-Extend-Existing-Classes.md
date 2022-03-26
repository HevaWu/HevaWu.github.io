---
layout: post
title: Objective-C - Categories Extend Existing Classes
date: 2020-10-13 17:28:00
comment_id: 102
categories: [Objective-C]
tags: [class, category]
---

# Customizing Existing Classes

> Objective-C allows you to add your own methods to existing classes through categories and class extensions.

## Categories Add Methods to Existing Classes

> If you need to add a method to an existing class, perhaps to add functionality to make it easier to do something in your own application, the easiest way is to use a category.
>
> The syntax to declare a category uses the @interface keyword, just like a standard Objective-C class description, but does not indicate any inheritance from a subclass. Instead, it specifies the name of the category in parentheses

```objective-c
/* Category */
@interface ClassName (CategoryName)
 
@end

// ------ Sample ------
// interface
#import "XYZPerson.h"
 
@interface XYZPerson (XYZPersonNameDisplayAdditions)
- (NSString *)lastNameFirstNameString;
@end

// implementation
#import "XYZPerson+XYZPersonNameDisplayAdditions.h"
 
@implementation XYZPerson (XYZPersonNameDisplayAdditions)
- (NSString *)lastNameFirstNameString {
    return [NSString stringWithFormat:@"%@, %@", self.lastName, self.firstName];
}
@end

#import "XYZPerson+XYZPersonNameDisplayAdditions.h"
@implementation SomeObject
- (void)someMethod {
    XYZPerson *person = [[XYZPerson alloc] initWithFirstName:@"John"
                                                    lastName:@"Doe"];
    XYZShoutingPerson *shoutingPerson =
                        [[XYZShoutingPerson alloc] initWithFirstName:@"Monica"
                                                            lastName:@"Robinson"];
 
    NSLog(@"The two people are %@ and %@",
         [person lastNameFirstNameString], [shoutingPerson lastNameFirstNameString]);
}
@end
```

## Class Extensions Extend the Internal Implementation

> Because no name is given in the parentheses, class extensions are often referred to as anonymous categories.
>
> Unlike regular categories, a class extension can add its own properties and instance variables to a class.
>
> The compiler will automatically synthesize the relevant accessor methods, as well as an instance variable, inside the primary class implementation.
>
> If you add any methods in a class extension, these must be implemented in the primary implementation for the class.

```objective-c
/* Declare class extension */
@interface ClassName ()
 
@end

// ------ Sample ------
@interface XYZPerson ()
@property NSObject *extraProperty;
@end
```

> The primary interface for a class is used to define the way that other classes are expected to interact with it. In other words, it’s the public interface to the class.
>
> Class extensions are often used to extend the public interface with additional private methods or properties for use within the implementation of the class itself.

```objective-c
@interface XYZPerson : NSObject
...
@property (readonly) NSString *uniqueIdentifier;
- (void)assignUniqueIdentifier;
@end

// In order for the XYZPerson class to be able to change the property internally, it makes sense to redeclare the property in a class extension that’s defined at the top of the implementation file for the class:
//
// This means that the compiler will now also synthesize a setter method, so any method inside the XYZPerson implementation will be able to set the property directly using either the setter or dot syntax.

@interface XYZPerson ()
@property (readwrite) NSString *uniqueIdentifier;
@end
 
@implementation XYZPerson
...
@end
```

## Consider Other Alternatives for Class Customization

> One of the primary goals of object-oriented programming is to write reusable code, which means that classes should be reusable in a variety of situations, wherever possible.
>
> one alternative is to leverage inheritance and leave those decisions in methods specifically designed to be overridden by subclasses. Although this does make it relatively easy to reuse the class, you still need to create a new subclass every time you want to make use of that original class.
> 
> Another alternative is for a class to use a `delegate` object. Any decisions that might limit reusability can be delegated to another object, which is left to make those decisions at runtime.

Objective-C also offers dynamic behavior through runtime system, ex: use associated references to object.

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html#//apple_ref/doc/uid/TP40011210-CH6-SW1>
