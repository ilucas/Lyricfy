//
//  NSMutableArray+Extensions.h
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Extensions)

- (NSMutableArray *)removeAllObjectsIdenticalTo:(id)object;
- (void)removeDuplicateObjectsWithOrderPreservation:(BOOL)flag;
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

//Order
- (void)reverse;
- (void)moveObjectFromIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex;

//Random
- (id)randomObject;
- (NSUInteger)randomObjectIndex;
- (NSUInteger)removeRandomObject;
- (void)shuffle;

@end