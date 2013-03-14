//
//  ITrack.h
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <ScriptingBridge/SBElementArray.h>

@class iTunesTrack, iTunesApplication;

enum {
    ITLyricWiki,
    ITmetroLyrics,
    ITlyricsFreak,
    ITCustomLyric,
};
typedef short ITSource;

@interface ITrack : NSObject

@property (nonatomic, weak) iTunesTrack *track;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, assign) NSInteger databeID;//TODO: convert databeID to NSNumber *databaseID
@property (nonatomic, assign) BOOL passedTheQueue;
//Lyrics
@property (nonatomic, strong) NSString *customLyric;
@property (nonatomic, strong) NSString *lyricWiki;//lyrics.wikia.com
@property (nonatomic, strong) NSString *metroLyrics;//metrolyrics.com
@property (nonatomic, strong) NSString *lyricsFreak;//lyricsfreak.com
//http://www.azlyrics.com

- (id)initWithiTunesTrack:(iTunesTrack *)track;

//+ (ITrack *)trackWithDatabaseID:(NSInteger)databaseID musicPlayList:(SBElementArray *)playlist;

- (void)setNewLyric:(ITSource)source iTunesApplication:(iTunesApplication *)iTunesApp;

+ (BOOL)validateLyricForTrack:(iTunesTrack *)track;

@end