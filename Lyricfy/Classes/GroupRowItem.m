//
//  GroupRowItem.m
//  Lyricfy
//
//  Created by Lucas on 12/10/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "GroupRowItem.h"

@implementation GroupRowItem

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        self.title = @"";
        self.location = -1;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title{
    self = [self init];
    if (self){
        self.title = title;
    }
    return self;
}

#pragma mark - KVC

- (NSString *)name{
    return self.title;
}

- (NSString *)artist{
    return nil;
}

#pragma mark - Extern

Class GroupRowItemClass(){
    return [GroupRowItem class];
}

@end