//
//  ITCustomTableCellView.h
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>

@class ITrack;

@interface ITTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSProgressIndicator *progress;

@property (nonatomic, weak) ITrack *track;

- (void)enableProgressIndicator:(BOOL)flag;

@end