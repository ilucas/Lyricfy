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
        //                                             name:NSApplicationDidFinishLaunchingNotification
        //                                           object:nil];
        
        //TableView content array
        array = [[NSMutableArray alloc] init];
        idxArray = [[NSMutableArray alloc] init];
        
        //Setup the tableView
        [tableView setFloatsGroupRows:YES];

        //Initialize the groupRow
        groupRow[0] = [[GroupRowItem alloc] initWithTitle:@"Finished"];
        groupRow[1] = [[GroupRowItem alloc] initWithTitle:@"Queue"];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
}

-(void)awakeFromNib{
    
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [tableView selectedRow];
    if (row != -1){
        ITrack *track = array[row];
        if ([track passedTheQueue])
            [lyricEditorController setupLyricEditorWithTrack:track];
    }else{
        [lyricEditorController resetEditorView];
    }
}

- (BOOL)tableView:(NSTableView *)sender isGroupRow:(NSInteger)row{
    __weak id item = array[row];
    return [item isKindOfClass:GroupRowItemClass()];
}

//The "group rows" and unfinished downloads can't be selected
- (BOOL)tableView:(NSTableView *)sender shouldSelectRow:(NSInteger)row{
    __weak id item = array[row];
    //return ![item isKindOfClass:GroupRowItemClass()];
    return ([item isKindOfClass:GroupRowItemClass()] ? NO : [item passedTheQueue]);
}

//The "group rows" have a small height, while all other rows have a larger height
- (CGFloat)tableView:(NSTableView *)sender heightOfRow:(NSInteger)row{
    __weak id item = array[row];
    static const CGFloat GroupRowHeight = 20.0;
    return ([item isKindOfClass:GroupRowItemClass()] ? GroupRowHeight : sender.rowHeight);
}

- (NSView *)tableView:(NSTableView *)sender viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    __weak id item = array[row];
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
    [self removeTrackAtIndex:rowIndex];
    return YES;
}

#pragma mark - Public

- (ITrack *)addTrack:(iTunesTrack *)track{
    NSNumber *databaseID = @(track.databaseID);
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
    if ([array[index] isKindOfClass:GroupRowItemClass()])
        return;//only remove tracks
    
    //NSLog(@"RTAI: %@",([NSThread isMainThread] ? @"main thread": @"other thread" ));
    //NSLog(@"RTAI: array = %ld - idx = %ld",array.count,idxArray.count);
    
    [idxArray removeObjectAtIndex:index];
    [array removeObjectAtIndex:index];
    [tableView removeRowAtIndex:index];
    groupRow[1].location -= 1;//up 1 position
    
    NSInteger position = groupRow[0].location + 1;
    __weak id item = array[position];
    
    if ([item isKindOfClass:GroupRowItemClass()]){
        [idxArray removeObjectAtIndex:position];
        [array removeObjectAtIndex:position];
        [tableView removeRowAtIndex:position];
        groupRow[0].location = -1;
        groupRow[1].location -= 1;//up 1 position
        
        if (array.count == 1){//remove the "queue" if is the only item in the TableView
            [idxArray removeObjectAtIndex:0];
            [array removeObjectAtIndex:0];
            [tableView removeRowAtIndex:0];
            groupRow[1].location = -1;
        }
    }
}

- (void)logArray{
    [array enumerateObjectsUsingBlock:^(id objj, NSUInteger idxx, BOOL *stop){
        if ([objj isKindOfClass:GroupRowItemClass()]){
            GroupRowItem *i = objj;
            NSLog(@"%ld - %@",idxx,[i name]);
        }else{
            ITrack *i = objj;
            NSLog(@"%ld - %@",idxx,[i name]);
        }
    }];
    
    [idxArray enumerateObjectsUsingBlock:^(id objj, NSUInteger idxx, BOOL *stop){
        if ([objj isKindOfClass:GroupRowItemClass()]){
            GroupRowItem *i = array[idxx];
            NSLog(@"%ld - %@",idxx,[i name]);
        }else{
            ITrack *i = array[idxx];
            NSLog(@"%ld - %@",idxx,[i name]);
        }
    }];
}

- (void)moveTrackUp:(NSInteger)index{
    //add the "main group"
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
    [tableView moveRowAtIndex:index toIndex:newIndex];
    

    __weak id item = [array lastObject];
    NSInteger pos = [array indexOfObject:item];
    NSLog(@"%ld , %ld",array.count,pos);
    
    
    return;
    if ([item isKindOfClass:GroupRowItemClass()]){
        NSInteger idx = [array count];
        
        //NSLog(@"idx = %ld - count = %ld",idx);
        
        return;
        __weak id item2 = array[idx];
        
        if (item == item2)
            NSLog(@"igual");
        return;
        [array removeObjectAtIndex:idx];
        [idxArray removeObjectAtIndex:idx];
        [tableView removeRowAtIndex:idx];
        [groupRow[1] setLocation:-1];
    }
}

- (void)startRowAnimationAtIndex:(NSInteger)index{
    NSInteger column = [tableView columnWithIdentifier:NSTableColumnIdentifier];
    ITTableCellView *cellView = [tableView viewAtColumn:column row:index makeIfNecessary:NO];
    if (cellView && ![cellView isKindOfClass:GroupRowItemClass()])//let's not animate a "Group Row"
        [cellView startAnimation];
}

- (void)stopRowAnimationAtIndex:(NSInteger)index{
    NSInteger column = [tableView columnWithIdentifier:NSTableColumnIdentifier];
    ITTableCellView *cellView = [tableView viewAtColumn:column row:index makeIfNecessary:NO];
    if (cellView && ![cellView isKindOfClass:GroupRowItemClass()])//let's not animate a "Group Row"
        [cellView stopAnimation];
}

@end