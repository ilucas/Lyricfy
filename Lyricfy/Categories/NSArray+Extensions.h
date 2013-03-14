//
//  NSArray+Extensions.h
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>

@interface NSArray (Extensions)
@property (readonly) BOOL isEmpty;

- (id)firstObject;

- (NSArray *)unionWithArray:(NSArray *)array;
- (NSArray *)intersectionWithArray:(NSArray *)array;
- (NSArray *)objectsNotInArray:(NSArray *)array;

- (NSArray *)arrayFromLocation:(NSInteger)location;

@end
