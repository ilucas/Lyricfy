//
//  AppController.m
//  Lyricfy
//
//  Created by Lucas on 11/12/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "AppController.h"
#import "AppController+Debug.h"
#import "ITTableView.h"
#import "iTunes.h"
#import "ITrack.h"
#import "lyricDownloader.h"

@interface AppController ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *idxArray;
@property (nonatomic, strong) iTunesApplication *iTunesApp;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (assign) BOOL allowTrackWithLyric;

- (void)openItunes;
- (SBElementArray *)musicPlayList;
- (void)restoreFromCoreData;
@end

@implementation AppController
@synthesize tableView, arrayController, array, idxArray, allowTrackWithLyric;
@synthesize iTunesApp, downloadQueue;
@synthesize lyricDelegate;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        //TableView content array
        array = [[NSMutableArray alloc] init];
        idxArray = [[NSMutableArray alloc] init];
        
        //Setup some defaults
        [self setAllowTrackWithLyric:YES];
        [tableView setFloatsGroupRows:YES];

        //Setup the Operation Queue
        downloadQueue = [[NSOperationQueue alloc] init];
        [downloadQueue setMaxConcurrentOperationCount:1];
        [downloadQueue setName:@"com.ilucas.Lyricfy.LyricDownloader"];
        
        //Initialize the iTunesApp
        iTunesApp = [SBApplication applicationWithBundleIdentifier:kiTunesIdentifier[0]];
        
        //Setup iTunes Notification
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(updateTrackInfo:)
                                                                name:kiTunesIdentifier[1]
                                                              object:nil];
        
        //Add a observer to applicationDidFinishLaunching
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:kApplicationDidFinishLaunching
                                                   object:nil];
    }
    return self;
}

- (void)awakeFromNib{
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    //Since applicationDidFinishLaunching is only called 1 time. we remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidFinishLaunching object:nil];
    
#if DEBUG
    [self activateDebugMenu];
#endif
    
    if (![iTunesApp isRunning])
        [self openItunes];
}

#pragma mark - iTunes

- (void)updateTrackInfo:(NSNotification *)notification {
    if (![iTunesApp isRunning])
        return;
    
    if (true){
        if (iTunesApp.playerState == iTunesEPlSPlaying){//is playing
            __weak iTunesTrack *currentTrack = [iTunesApp currentTrack];
            if ([ITrack validateLyricForTrack:currentTrack]){//Check if the track already has a lyric
                NSNumber *databaseID = [NSNumber numberWithInteger:currentTrack.databaseID];
                if (![idxArray containsObject:databaseID]){//check if the track isn't in the queue
                    ITrack *track = [[ITrack alloc] initWithiTunesTrack:currentTrack];
                    [arrayController addObject:track];
                    [idxArray addObject:databaseID];
                    lyricDownloader *downloader = [[lyricDownloader alloc] initWithTrack:track];
                    [downloader setCompletionBlock:^(ITrack *track, NSInteger responseCode){
                        if (responseCode == 200){
                            //do something
                        }else {
                            NSInteger index = [idxArray indexOfObject:databaseID];
                            [tableView removeRowAtIndex:index];
                            [idxArray removeObjectAtIndex:index];
                            [array removeObjectAtIndex:index];
                        }
                    }];
                    [downloadQueue addOperation:downloader];
                }
            }
        }
    }
}

- (void)openItunes{
    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:kiTunesIdentifier[0]
                                                         options:NSWorkspaceLaunchAsync
                                  additionalEventParamDescriptor:nil
                                                launchIdentifier:nil];
}

- (SBElementArray *)musicPlayList{
    iTunesSource *sauce = [[iTunesApp sources] objectAtIndex:0];
    iTunesPlaylist *library = [[sauce playlists] objectAtIndex:1];
    return [library tracks];
}

#pragma mark - lyricEditorDelegate

- (void)applyLyric:(ITSource)source forTrack:(ITrack *)track{
    NSInteger index = [tableView selectedRow];
    [track setNewLyric:source iTunesApplication:iTunesApp];
    [tableView removeRowAtIndex:index];
    [idxArray removeObjectAtIndex:index];
    [array removeObjectAtIndex:index];
}

#pragma mark - Core Data

- (void)restoreFromCoreData{
    
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [tableView selectedRow];
    if (row != -1){
        ITrack *track = [array objectAtIndex:row];
        if ([track passedTheQueue])
            [lyricDelegate setupLyricEditorWithTrack:track];
    }else{
        [lyricDelegate setupLyricEditorWithTrack:nil];
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

#pragma mark - Singleton

+ (id)sharedController {
    static AppController *sharedAppController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAppController = [[self alloc] init];
    });
    return sharedAppController;
}

@end