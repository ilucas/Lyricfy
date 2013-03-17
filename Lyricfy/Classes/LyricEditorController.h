//
//  lyricEditorController.h
//  Lyricfy
//
//  Created by Lucas on 11/23/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import <Cocoa/Cocoa.h>
#import "lyricEditorDelegate.h"

@interface LyricEditorController : NSObject <NSTextViewDelegate>

@property IBOutlet id<lyricEditorControllerDelegate> delegate;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSScrollView *textScrollView;
@property (weak) IBOutlet NSButton *applyButton;
@property (weak) IBOutlet NSView *scopeView;

@property (weak) IBOutlet NSButton *bttLyricWiki;
@property (weak) IBOutlet NSButton *bttMetroLyric;
@property (weak) IBOutlet NSButton *bttCustom;

- (IBAction)applyButton:(id)sender;
- (IBAction)lyricButton:(id)sender;

- (void)setupLyricEditorWithTrack:(ITrack *)track;
- (void)resetEditorView;
@end