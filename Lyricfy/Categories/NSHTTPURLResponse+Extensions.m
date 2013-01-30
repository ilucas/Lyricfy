//
//  NSHTTPURLResponse+Extensions.m
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import "NSHTTPURLResponse+Extensions.h"

@implementation NSHTTPURLResponse (Extensions)

- (NSString *)localizedStatusCode{
    return [NSHTTPURLResponse localizedStringForStatusCode:[self statusCode]];
}

@end