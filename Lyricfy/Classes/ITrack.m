//
//  ITrack.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "ITrack.h"
#import "iTunes.h"

@interface ITrack ()
- (void)applyLyricUsingAppleScript:(NSString *)aLyric;
@end

@implementation ITrack
@synthesize track = _track;
@synthesize name, artist, databeID;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        [self setPassedTheQueue:NO];
        [self setLyricWiki:[NSString string]];
        [self setLyricsFreak:[NSString string]];
        [self setMetroLyrics:[NSString string]];
        [self setCustomLyric:[NSString string]];
        [self setName:[NSString string]];
        [self setArtist:[NSString string]];
    }
    return self;
}

- (id)initWithiTunesTrack:(iTunesTrack *)track{
    self = [self init];
    if (self) {
        [self setName:track.name];
        [self setArtist:track.artist];
        [self setDatabeID:track.databaseID];
        [self setTrack:track];
    }
    return self;
}

- (void)setNewLyric:(ITSource)source{
    NSString *aLyric;
    
    switch (source){
        case ITLyricWiki:
            aLyric = _lyricWiki;
            break;
            
        case ITmetroLyrics:
            aLyric = _metroLyrics;
            break;
            
        case ITCustomLyric:
            aLyric = _customLyric;
            break;
            
        default:
            return;
    }
    
    if (_track)
        [_track setLyrics:aLyric];
    else
        [self performSelectorInBackground:@selector(applyLyricUsingAppleScript:) withObject:aLyric];
}

/*+ (ITrack *)trackWithDatabaseID:(NSInteger)databaseID musicPlayList:(SBElementArray *)playlist{
 __block NSArray *array = [NSArray new];
 dispatch_sync(dispatch_queue_create("com.ilucas.Lirycfy.CoreDataHelper", NULL), ^{
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"databeID == 4661"];
 array = [playlist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"databeID == 4661"]];
 });
 
 NSLog(@"%ld",array.count);
 
 ITrack *track = [[ITrack alloc] initWithiTunesTrack:[array lastObject]];
 return track;
 return nil;
 }*/

#pragma mark - AppleScript

- (void)applyLyricUsingAppleScript:(NSString *)aLyric{
    NSLog(@"Apply lyric using AppleScript");
    //return;
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *scriptURL = [[NSURL alloc] initFileURLWithPath:[bundle pathForResource:@"LyricScript" ofType:@"scpt"]];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
    [script callHandler:@"SetLyric" withParameters:[NSNumber numberWithInteger:databeID], aLyric, nil];
}

#pragma mark - Extern

+ (BOOL)validateLyricForTrack:(iTunesTrack *)track{
    NSString *lyric = [[track lyrics] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [lyric isEqualToString:@""];
}

@end