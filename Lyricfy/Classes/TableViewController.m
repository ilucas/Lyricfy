//
//  TableViewController.m
//  Lyricfy
//
//  Created by Lucas on 3/15/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "TableViewController.h"
#import "LyricEditorController.h"
#import "iTunes.h"
#import "ITrack.h"

@interface TableViewController (){
    GroupRowItem *groupRow[2];
}
@end

@implementation TableViewController
@synthesize lyricEditorController;
@synthesize tableView, arrayController, array, idxArray;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        //Add a observer to applicationDidFinishLaunching
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                         selector:@selector(applicationDidFinishLaunching:)
        //                                             name:kApplicationDidFinishLaunching
        //                                           object:nil];
        
        //TableView content array
        array = [[NSMutableArray alloc] init];
        idxArray = [[NSMutableArray alloc] init];
        
        //Setup the tableView
        [tableView setFloatsGroupRows:YES];

        //Initialize the groupRow
        groupRow[0] = [[GroupRowItem alloc] initWithTitle:@"Main"];
        groupRow[1] = [[GroupRowItem alloc] initWithTitle:@"Queue"];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidFinishLaunching object:nil];
    
}

-(void)awakeFromNib{
    
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [tableView selectedRow];
    if (row != -1){
        ITrack *track = [array objectAtIndex:row];
        if ([track passedTheQueue])
            [lyricEditorController setupLyricEditorWithTrack:track];
    }else{
        [lyricEditorController setupLyricEditorWithTrack:nil];
    }
}

- (BOOL)tableView:(NSTableView *)sender isGroupRow:(NSInteger)row{
    __weak id item = [array objectAtIndex:row];
    return [item isKindOfClass:GroupRowItemClass()];
}

//The "group rows" and unfinished downloads can't be selected
- (BOOL)tableView:(NSTableView *)sender shouldSelectRow:(NSInteger)row{
    __weak id item = [array objectAtIndex:row];
    //return ![item isKindOfClass:GroupRowItemClass()];
    return ([item isKindOfClass:GroupRowItemClass()] ? NO : [item passedTheQueue]);
}

// The "group rows" have a small height, while all other rows have a larger height
- (CGFloat)tableView:(NSTableView *)sender heightOfRow:(NSInteger)row {
    __weak id item = [array objectAtIndex:row];
    static const CGFloat GroupRowHeight = 20.0;
    return ([item isKindOfClass:GroupRowItemClass()] ? GroupRowHeight : sender.rowHeight);
}

- (NSView *)tableView:(NSTableView *)sender viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    __weak id item = [array objectAtIndex:row];
    if ([item isKindOfClass:GroupRowItemClass()]){
        NSTableCellView *cellView = [sender makeViewWithIdentifier:kGroupCellIdentifier owner:self];
        [cellView.textField.cell setBackgroundStyle:NSBackgroundStyleRaised];
        [cellView.textField setStringValue:[item title]];
        return cellView;
    }else{
        ITTableCellView *cellView = [sender makeViewWithIdentifier:kTrackCellIdentifier owner:self];
        [cellView setTrack:item];
        return cellView;
    }
}

//delegate called when pressed the delete key on the TableView
- (BOOL)tableView:(NSTableView *)sender shouldDeleteRow:(NSInteger)rowIndex{
    //since a "Group Row" can't be selected, there's no need to test if is a "Group Row"
    [idxArray removeObjectAtIndex:rowIndex];
    [array removeObjectAtIndex:rowIndex];
    return YES;
}

#pragma mark - Public

- (ITrack *)addTrack:(iTunesTrack *)track{
    NSNumber *databaseID = [NSNumber numberWithInteger:track.databaseID];
    if (![idxArray containsObject:databaseID]){//check if the track isn't in the queue
        ITrack *_track = [[ITrack alloc] initWithiTunesTrack:track];
        if ([array isEmpty]){
            [arrayController addObject:groupRow[1]];
            [idxArray addObject:groupRow[1]];
            [groupRow[1] setLocation:0];
        }
        [arrayController addObject:_track];//put the track in the last position
        [idxArray addObject:databaseID];
        return _track;
    }
    return nil;
}

- (void)removeTrackAtIndex:(NSInteger)index{
    if ([[array objectAtIndex:index] isKindOfClass:GroupRowItemClass()])
        return;//only remove tracks
        
    [tableView beginUpdates];
    [tableView removeRowAtIndex:index];
    [idxArray removeObjectAtIndex:index];
    [array removeObjectAtIndex:index];
    
    groupRow[1].location -= 1;//up 1 position
    
    NSInteger position = groupRow[0].location + 1;
    __weak id item = [array objectAtIndex:position];
    
    if ([item isKindOfClass:GroupRowItemClass()]){
        [tableView removeRowAtIndex:position];
        [idxArray removeObjectAtIndex:position];
        [array removeObjectAtIndex:position];
        groupRow[0].location = -1;
        groupRow[1].location -= 1;//up 1 position
        
        if (array.count == 1){//remove the "queue" if is the only item in the TableView
            [tableView removeRowAtIndex:0];
            [idxArray removeObjectAtIndex:0];
            [array removeObjectAtIndex:0];
            groupRow[1].location = -1;
        }
    }
    [tableView endUpdates];
    //[tableView reloadData];
}

- (void)moveTrackUp:(NSInteger)index{
    [tableView beginUpdates];
    //add the main group
    if (groupRow[0].location < 0){
        [groupRow[0] setLocation:0];
        [arrayController insertObject:groupRow[0] atArrangedObjectIndex:0];
        [idxArray insertObject:groupRow[0] atIndex:0];
        groupRow[1].location = 1;//now the "queue group" is temporary in the position 1
        index += 1;
    }
    
    NSInteger newIndex = groupRow[1].location;
    groupRow[1].location += 1;//down 1 position
    
    [array moveObjectFromIndex:index toIndex:newIndex];
    [idxArray moveObjectFromIndex:index toIndex:newIndex];
    
    //[tableView moveRowAtIndex:index toIndex:newIndex];
    
    [tableView removeRowAtIndex:index withAnimation:NSTableViewAnimationEffectGap];
    [tableView insertRowAtIndex:newIndex withAnimation:NSTableViewAnimationEffectGap];
    
    [tableView endUpdates];
    //[tableView reloadData];   
}

- (void)startRowAnimationAtIndex:(NSInteger)index{
    NSInteger column = [tableView columnWithIdentifier:NSTableColumnIdentifier];
    ITTableCellView *cellView = [tableView viewAtColumn:column row:index makeIfNecessary:NO];
    if (cellView && [cellView isKindOfClass:[ITTableCellView class]])//let's not animate a "Group Row"
        [cellView startAnimation];
}

- (void)stopRowAnimationAtIndex:(NSInteger)index{
    NSInteger column = [tableView columnWithIdentifier:NSTableColumnIdentifier];
    ITTableCellView *cellView = [tableView viewAtColumn:column row:index makeIfNecessary:NO];
    if (cellView && [cellView isKindOfClass:[ITTableCellView class]])//let's not animate a "Group Row"
        [cellView stopAnimation];
}

@end