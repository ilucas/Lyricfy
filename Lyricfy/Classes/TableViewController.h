//
//  TableViewController.h
//  Lyricfy
//
//  Created by Lucas on 3/15/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "ITTableView.h"

@class LyricEditorController, ITrack, iTunesTrack;

@interface TableViewController : NSObject
@property (weak) IBOutlet ITTableView *tableView;
@property (weak) IBOutlet NSArrayController *arrayController;
@property (weak) IBOutlet LyricEditorController *lyricEditorController;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *idxArray;

- (ITrack *)addTrack:(iTunesTrack *)track;
- (void)removeTrackAtIndex:(NSInteger)index;
- (void)moveTrackUp:(NSInteger)index;
- (void)startRowAnimationAtIndex:(NSInteger)index;
- (void)stopRowAnimationAtIndex:(NSInteger)index;
@end
