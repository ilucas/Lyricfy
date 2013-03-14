//
//  AppController.h
//  Lyricfy
//
//  Created by Lucas on 11/12/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "ITTableView.h"
#import "lyricEditorDelegate.h"

@class ITTableView;

@interface AppController : NSObject <ITTableViewDelegate, lyricEditorControllerDelegate>

@property IBOutlet id<lyricEditorDelegate> lyricDelegate;
@property (weak) IBOutlet ITTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;

+ (id)sharedController;

@end

/* TODO:
 http://blog.shpakovski.com/2011/07/cocoa-popup-window-in-status-bar.html
*/