//
//  AppController.h
//  Lyricfy
//
//  Created by Lucas on 11/12/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "TableViewController.h"
#import "lyricEditorDelegate.h"

@interface AppController : NSObject <lyricEditorControllerDelegate>
@property (nonatomic, weak) IBOutlet TableViewController *tableViewController;

+ (id)sharedController;

@end