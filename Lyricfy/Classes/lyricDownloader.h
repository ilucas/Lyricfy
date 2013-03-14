//
//  lyricDownloader.h
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>

@class ITrack;
@protocol lyricDownloaderDelegate;

@interface lyricDownloader : NSOperation
@property id<lyricDownloaderDelegate> delegate;
@property (nonatomic, weak) ITrack *track;

- (id)initWithTrack:(ITrack *)track;
- (void)setCompletionBlock:(void (^)(ITrack *track, NSInteger responseCode))block;
@end

@protocol lyricDownloaderDelegate <NSObject>
- (void)lyricDownloader:(lyricDownloader *)lyricDownloader WillBeginProcessingTrack:(ITrack *)track;
- (void)lyricDownloader:(lyricDownloader *)lyricDownloader didFinishedDownloadingLyricForTrack:(ITrack *)track withResponseCode:(NSInteger)responseCode;
@end