//
//  GeneralPreferencesViewController.h
//  Lyricfy
//
//  Created by Lucas on 19/05/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (weak) IBOutlet NSButton *lyricWiki;//lyrics.wikia.com
@property (weak) IBOutlet NSButton *metroLyrics;//metrolyrics.com
@property (weak) IBOutlet NSButton *lyricsFreak;//lyricsfreak.com

@property IBOutlet NSImageView *imgv;
@end
