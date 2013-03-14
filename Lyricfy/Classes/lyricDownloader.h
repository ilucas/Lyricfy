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

@interface lyricDownloader : NSOperation
@property (nonatomic, weak) ITrack *track;

- (id)initWithTrack:(ITrack *)track;
- (void)setCompletionBlock:(void (^)(ITrack *track, NSInteger responseCode))block;
@end