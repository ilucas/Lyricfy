//
//  NSAppleScript+Handler.h
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>

@interface NSAppleScript (Handler)

- (NSAppleEventDescriptor *)callHandler:(NSString *)handlerName withArrayOfParameters:(NSArray *)parameterList;
- (NSAppleEventDescriptor *)callHandler:(NSString *)handlerName withParameters:(id)firstParameter, ...NS_REQUIRES_NIL_TERMINATION;

@end