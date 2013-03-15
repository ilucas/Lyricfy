//
//  AppDelegate.h
//  Lyricfy
//
//  Created by Lucas on 11/12/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>

@class INAppStoreWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSSplitViewDelegate>
@property (assign) IBOutlet INAppStoreWindow *window;
@property (weak) IBOutlet NSSplitView *splitView;
@end
