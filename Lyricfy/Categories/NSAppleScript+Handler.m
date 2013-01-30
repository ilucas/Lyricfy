//
//  NSAppleScript+Handler.m
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import <Carbon/Carbon.h>
#import "NSAppleScript+Handler.h"

@implementation NSAppleScript (Handler)

- (NSAppleEventDescriptor *)callHandler:(NSString *)handlerName withArrayOfParameters:(NSArray *)parameterList{
    NSAppleEventDescriptor *_parameterList = [NSAppleEventDescriptor listDescriptor];
    int index = 1;
    
    for (id obj in parameterList){
        if ([obj isKindOfClass:[NSNumber class]])
			[_parameterList insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[obj int32Value]] atIndex:(index++)];
        else if ([obj isKindOfClass:[NSString class]])
			[_parameterList insertDescriptor:[NSAppleEventDescriptor descriptorWithString:obj] atIndex:(index++)];
        else if ([obj isKindOfClass:[NSAppleEventDescriptor class]])
			[_parameterList insertDescriptor:obj atIndex:(index++)];
    }
    
    NSAppleEventDescriptor *theEvent = [NSAppleEventDescriptor appleEventWithEventClass:typeAppleScript
                                                                                eventID:kASSubroutineEvent
                                                                       targetDescriptor:nil
                                                                               returnID:kAutoGenerateReturnID
                                                                          transactionID:kAnyTransactionID];
    
    NSAppleEventDescriptor *theHandlerName = [NSAppleEventDescriptor descriptorWithString:handlerName];
    [theEvent setDescriptor:theHandlerName forKeyword:keyASSubroutineName];
    [theEvent setDescriptor:_parameterList forKeyword:keyDirectObject];
    
    return [self executeAppleEvent:theEvent error:nil];
}

- (NSAppleEventDescriptor *)callHandler:(NSString *)handlerName withParameters:(id)firstParameter, ...{
    va_list args;
    int index = 1;
    NSAppleEventDescriptor *parameterList = [NSAppleEventDescriptor listDescriptor];
    
    va_start(args, firstParameter);
    for (id arg = firstParameter; arg != nil; arg = va_arg(args, id)){
        if ([arg isKindOfClass:[NSNumber class]])
			[parameterList insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[arg int32Value]] atIndex:(index++)];
        else if ([arg isKindOfClass:[NSString class]])
			[parameterList insertDescriptor:[NSAppleEventDescriptor descriptorWithString:arg] atIndex:(index++)];
        else if ([arg isKindOfClass:[NSAppleEventDescriptor class]])
			[parameterList insertDescriptor:arg atIndex:(index++)];
    }
    va_end(args);
    
    NSAppleEventDescriptor *theEvent = [NSAppleEventDescriptor appleEventWithEventClass:typeAppleScript
                                                                                eventID:kASSubroutineEvent
                                                                       targetDescriptor:nil
                                                                               returnID:kAutoGenerateReturnID
                                                                          transactionID:kAnyTransactionID];
    
    NSAppleEventDescriptor *theHandlerName = [NSAppleEventDescriptor descriptorWithString:handlerName];
    [theEvent setDescriptor:theHandlerName forKeyword:keyASSubroutineName];
    [theEvent setDescriptor:parameterList forKeyword:keyDirectObject];
    
    return [self executeAppleEvent:theEvent error:nil];
}

@end
