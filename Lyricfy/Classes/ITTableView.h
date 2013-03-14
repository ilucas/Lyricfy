//
//  ITCustomTableView.h
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "ITTableRowView.h"
#import "ITTableCellView.h"
#import "GroupRowItem.h"

@protocol ITTableViewDelegate <NSTableViewDelegate>
@optional
- (BOOL)tableView:(NSTableView *)aTableView shouldDeleteRow:(NSInteger)rowIndex;
//- (NSView *)tableView:(NSTableView *)sender viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//– tableView:didDragTableColumn:
//- (void)tableView:(NSTableView *)movecell

@end

@interface ITTableView : NSTableView

- (void)setDelegate:(id <ITTableViewDelegate>)delegate;
- (id <ITTableViewDelegate>)delegate;

- (void)removeRowAtIndex:(NSInteger)index;
- (void)removeRowAtIndex:(NSInteger)index withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)insertRowAtIndex:(NSInteger)index withAnimation:(NSTableViewAnimationOptions)animationOptions;

@end
//http://jwilling.com/post/40530077255/optimized-scrolling-in-a-view-based-nstableview