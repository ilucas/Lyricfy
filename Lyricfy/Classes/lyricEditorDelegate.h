//
//  lyricEditorDelegate.h
//  Lyricfy
//
//  Created by Lucas on 11/25/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Foundation/Foundation.h>
#import "ITrack.h"

@class lyricEditorController;

@protocol lyricEditorDelegate <NSObject>
@required
- (void)setupLyricEditorWithTrack:(ITrack *)track;
@end

@protocol lyricEditorControllerDelegate <NSObject>
@required
- (void)applyLyric:(ITSource)source forTrack:(ITrack *)track;
@end
