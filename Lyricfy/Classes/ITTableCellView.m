//
//  ITCustomTableCellView.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "ITTableCellView.h"
#import "ITrack.h"

@implementation ITTableCellView
@synthesize name, artist, progress;
@synthesize track = _track;

#pragma mark - Lifecycle

- (void)setTrack:(ITrack *)track{
    _track = track;
    [name setStringValue:track.name];
    [artist setStringValue:track.artist];
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self enableProgressIndicator:NO];
        
    }
    return self;
}

- (void)awakeFromNib{

}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
}

- (void)enableProgressIndicator:(BOOL)flag{
    if (flag){
        [progress setHidden:NO];
        [progress startAnimation:progress];
    }else{
        [progress setHidden:YES];
        [progress stopAnimation:progress];
    }
}


@end