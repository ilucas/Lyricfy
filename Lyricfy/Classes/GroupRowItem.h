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

//Making the Class, KVC Compliant so the NSearchField don't throw a exception
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *artist;

- (id)initWithTitle:(NSString *)title;

Class GroupRowItemClass();

@end