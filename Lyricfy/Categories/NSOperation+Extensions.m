//
//  NSOperation+Extensions.m
//  Lyricfy
//
//  Created by Lucas on 2/10/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//

#import "NSOperation+Extensions.h"

@implementation NSOperation (Extensions)

- (void)startAndWaitUntilFinished{
    [self start];
    [self waitUntilFinished];
}

@end
