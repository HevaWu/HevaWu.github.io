---
layout: post
title: Objective-C - Error Objects Are Used for Runtime Problems
date: 2020-11-16 21:57:00
comment_id: 110
categories: [Objective-C]
tags: [Error]
---

# Dealing with Errors

> All other errors—including runtime problems such as running out of disk space or not being able to access a web service—are represented by instances of the `NSError` class.

## Use NSError for Most Errors

> An NSError object contains a numeric error code, domain and description, as well as other relevant information packaged in a user info dictionary.
>
> Rather than making the requirement that every possible error have a unique numeric code, Cocoa and Cocoa Touch errors are divided into domains

### Use Delegate Methods Alert Errors

```objective-c
// ------ Sample ------
// If an error occurs, this delegate method will be called to provide 
// you with an NSError object to describe the problem.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
```

### Pass Errors by Reference

```objective-c
// ------ Sample ------
- (BOOL)writeToURL:(NSURL *)aURL
           options:(NSDataWritingOptions)mask
             error:(NSError **)errorPtr;

// before calling this method
// create pointer first for passing its address
NSError *anyError;
BOOL success = [receivedData writeToURL:someLocalFileURL
								options:0
									error:&anyError];
if (!success) {
	NSLog(@"Write failed with error: %@", anyError);
	// present error to user
}
```

> When dealing with errors passed by reference, it’s important to test the return value of the method to see whether an error occurred, as shown above. Don’t just test to see whether the error pointer was set to point to an error.

### Recover Error to User

> The best user experience is for your app to recover transparently from an error.

### Create Own Errors

It required to define own error domain to create own `NSError` objects. This error domain should be the bellow form:

```objective-c
com.companyName.appOrFrameworkName.ErrorDomain

// ------ Sample ------
NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
NSString *desc = NSLocalizedString(@"Unable to…", @"");
NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };

NSError *error = [NSError errorWithDomain:domain
									 code:-101
								 userInfo:userInfo];

// pass error back
- (BOOL)doSomethingThatMayGenerateAnError:(NSError **)errorPtr;
- (BOOL)doSomethingThatMayGenerateAnError:(NSError **)errorPtr {
    ...
    // error occurred
    if (errorPtr) {
        *errorPtr = [NSError errorWithDomain:...
                                        code:...
                                    userInfo:...];
    }
    return NO;
}
```

## Exceptions Are Used for Programming Errors

> As with NSError, exceptions in Cocoa and Cocoa Touch are objects, represented by instances of the `NSException` class

```objective-c
// throw exception
@try {
	// do something that might throw an exception
}
@catch (NSException *exception) {
	// deal with the exception
}
@finally {
	// optional block of clean-up code
	// executed whether or not an exception occurred
}
```

#### Reference

- <https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/ErrorHandling/ErrorHandling.html#//apple_ref/doc/uid/TP40011210-CH9-SW1>
