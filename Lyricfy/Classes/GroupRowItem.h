//
//  GroupRowItem.h
//  Lyricfy
//
//  Created by Lucas on 12/10/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>

@interface GroupRowItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger location;

- (id)initWithTitle:(NSString *)title;

Class GroupRowItemClass();

@end