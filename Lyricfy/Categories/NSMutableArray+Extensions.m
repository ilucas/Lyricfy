//
//  NSMutableArray+Extensions.m
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import "NSMutableArray+Extensions.h"

@implementation NSMutableArray (Extensions)

//From: NSMutableArray+MMextensions By Michael MacCallum
- (NSMutableArray *)removeAllObjectsIdenticalTo:(id)object{
    NSMutableArray *temp = [self mutableCopy];
    for (id obj in self){
        if (obj == object)
            [temp removeObject:obj];
    }
    [self removeAllObjects];
    [self addObjectsFromArray:temp];
    return self;
}

- (void)removeDuplicateObjectsWithOrderPreservation:(BOOL)keepOrder{
    if ([self count] > 0){
        if (keepOrder) {
            NSMutableSet *set = [NSMutableSet set];
            NSMutableArray *temp = [NSMutableArray array];
            for (id obj in self) {
                if (![set containsObject:obj]) {
                    [set addObject:obj];
                    [temp addObject:obj];
                }
            }
            [self removeAllObjects];
            [self addObjectsFromArray:temp];
        }else{
            NSArray *temp = [[NSSet setWithArray:self] allObjects];
            [self removeAllObjects];
            [self addObjectsFromArray:temp];
        }
    }
}

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index{
    [self insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, objects.count)]];
}

- (void)reverse{
    if (self.count > 1){
        NSMutableArray *reversed = [[[self reverseObjectEnumerator] allObjects] mutableCopy];
        [self removeAllObjects];
        [self addObjectsFromArray:reversed];
    }
}

- (void)moveObjectFromIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex{
    if (index != toIndex) {
        id obj = [self objectAtIndex:toIndex];
        [self removeObjectAtIndex:toIndex];
        if (index >= [self count])
            [self addObject:obj];
        else
            [self insertObject:obj atIndex:toIndex];
    }
}

- (id)randomObject{
    if ([self count] > 0)
        return [self objectAtIndex:(arc4random() % self.count)];
    else
        return nil;
}

- (NSUInteger)randomObjectIndex{
    if ([self count] > 0)
        return (arc4random() % self.count);
    else
        return -1;
}

- (NSUInteger)removeRandomObject{
    if ([self count] > 0){
        NSUInteger index = (arc4random() % self.count);
        [self removeObjectAtIndex:index];
        return index;
    }else{
        return -1;
    }
}

- (void)shuffle{
	for (int i=0; i<([self count]-2); i++)
        [self exchangeObjectAtIndex:i withObjectAtIndex:(i + (arc4random() % (self.count - i)))];
}

@end
