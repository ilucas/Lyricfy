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
#import "iTunes.h"
#import "ITrack.h"
#import "lyricDownloader.h"

@interface AppController () <lyricDownloaderDelegate>
@property (nonatomic, strong) iTunesApplication *iTunesApp;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (assign) BOOL allowTrackWithLyric;

- (void)openItunes;
- (SBElementArray *)musicPlayList;
- (void)restoreFromCoreData;
@end

@implementation AppController
@synthesize tableViewController;
@synthesize iTunesApp, downloadQueue;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {        
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
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];

    }
    return self;
}

- (void)awakeFromNib{
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    //Since applicationDidFinishLaunching is only called 1 time. we remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
        
#if DEBUG
    [self activateDebugMenu];
#endif
    
    //if (![iTunesApp isRunning])
        //[self openItunes];
}

#pragma mark - iTunes

- (void)updateTrackInfo:(NSNotification *)notification {
    if (![iTunesApp isRunning])
        return;
    
    if (true){
        if (iTunesApp.playerState == iTunesEPlSPlaying){//is playing
            __weak iTunesTrack *currentTrack = [iTunesApp currentTrack];
            if ([ITrack validateLyricForTrack:currentTrack]){//Check if the track already has a lyric
                __weak ITrack *track = [tableViewController addTrack:currentTrack];
                if (track){
                    lyricDownloader *downloader = [[lyricDownloader alloc] initWithTrack:track];
                    [downloader setDelegate:self];
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
    iTunesSource *sauce = [iTunesApp sources][0];
    iTunesPlaylist *library = [sauce playlists][1];
    return [library tracks];
}

#pragma mark - lyricDownloaderDelegate

- (void)lyricDownloader:(lyricDownloader *)lyricDownloader WillBeginProcessingTrack:(ITrack *)track{
    NSInteger index = [[tableViewController idxArray] indexOfObject:@(track.databeID)];
    [tableViewController startRowAnimationAtIndex:index];
}

- (void)lyricDownloader:(lyricDownloader *)lyricDownloader didFinishedDownloadingLyricForTrack:(ITrack *)track withResponseCode:(NSInteger)responseCode{
    NSInteger index = [[tableViewController idxArray] indexOfObject:@(track.databeID)];
    [tableViewController stopRowAnimationAtIndex:index];
    
    if (responseCode == 200)
        [tableViewController moveTrackUp:index];
    else
        [tableViewController removeTrackAtIndex:index];
}

#pragma mark - lyricEditorDelegate

- (void)applyLyric:(ITSource)source forTrack:(ITrack *)track{
    [track setNewLyric:source];
    NSInteger index = [[tableViewController tableView] selectedRow];
    [tableViewController removeTrackAtIndex:index];
}

#pragma mark - Core Data

- (void)restoreFromCoreData{
    
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