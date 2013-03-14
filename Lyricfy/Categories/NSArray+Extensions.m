//
//  NSArray+Extensions.m
//  Cocoa+Extensions
//
//  Created by iLucas.
//  http://github.com/ilucas/Cocoa-Extensions
//
//  Copyright (c) 2012-2013. All rights reserved.
//  Licensed under the New BSD License
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (id)firstObject{
    if (self.count > 0)
        return [self objectAtIndex:0];
    else
        return nil;
}

- (BOOL)isEmpty{
    return !(self.count > 0);
}

- (NSArray *)uniqueMembers{
	NSMutableArray *array = [self mutableCopy];
	for (id object in self) {
		[array removeObjectIdenticalTo:object];
		[array addObject:object];
	}
	return array;
}

- (NSArray *)unionWithArray:(NSArray *)array{
     if (!array)
         return self;
    
     return [[self arrayByAddingObjectsFromArray:array] uniqueMembers];
}

- (NSArray *)intersectionWithArray:(NSArray *)array{
    NSMutableArray *_array = [self mutableCopy];
	for (id object in self) {
		if (![array containsObject:object])
			[_array removeObjectIdenticalTo:object];
	}
	return [_array uniqueMembers];
}

- (NSArray *)objectsNotInArray:(NSArray *)array{
    NSMutableArray *_array = [NSMutableArray array];
    
	for (id object in self){
		if(![array containsObject:object])
			[_array addObject:object];
	}
    
	return [NSArray arrayWithArray:_array];
}

- (NSArray *)arrayFromLocation:(NSInteger)location{
    if (location == 0) return self;
    if (location >= [self count]) return [NSArray array];
    return [self subarrayWithRange:NSMakeRange(location, (self.count - location))];
}

@end