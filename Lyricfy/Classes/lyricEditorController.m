//
//  lyricEditorController.m
//  Lyricfy
//
//  Created by Lucas on 11/23/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "lyricEditorController.h"
#import "ITrack.h"
#import "iTunes.h"

@interface lyricEditorController ()
@property (nonatomic, weak) ITrack *track;
- (void)reset;
@end

@implementation lyricEditorController
@synthesize delegate;
@synthesize track = _track;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:kApplicationDidFinishLaunching
                                                   object:nil];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    //Since applicationDidFinishLaunching: is only called 1 time. we remove the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidFinishLaunching object:nil];

    [_bttLyricWiki setTag:0];
    [_bttMetroLyric setTag:1];
    [_bttCustom setTag:2];
}

- (void)awakeFromNib{
    [self reset];
}

#pragma mark - UI

- (IBAction)applyButton:(id)sender {
    ITSource sauce = ITmetroLyrics; //for now metroLyrics is the default
    if (_bttCustom.state == NSOnState)
        sauce = ITCustomLyric;
    else if (_bttLyricWiki.state == NSOnState)
        sauce = ITLyricWiki;
    else if (_bttMetroLyric.state == NSOnState)
        sauce = ITmetroLyrics;
    
    //TODO: fix this bug. when called, none button is selectec
    
    [delegate applyLyric:sauce forTrack:self.track];
    [self reset];
}

- (IBAction)lyricButton:(id)sender{
    switch ([sender tag]){
        case 0://LyricWiki
            [_bttLyricWiki setState:NSOnState];
            [_bttMetroLyric setState:NSOffState];
            [_bttCustom setState:NSOffState];
            [_textView setString:_track.lyricWiki];
            break;
        case 1://MetroLyric
            [_bttLyricWiki setState:NSOffState];
            [_bttMetroLyric setState:NSOnState];
            [_bttCustom setState:NSOffState];
            [_textView setString:_track.metroLyrics];
            break;
        case 2://Custom
            [_bttLyricWiki setState:NSOffState];
            [_bttMetroLyric setState:NSOffState];
            [_bttCustom setState:NSOnState];
            [_textView setString:_track.customLyric];
            break;
        default:
            break;
    }
}

- (void)reset{
    [_applyButton setHidden:YES];
    [_textScrollView setHidden:YES];
    [_textView setString:@""];

    [_bttLyricWiki setHidden:YES];
    [_bttLyricWiki setState:NSOffState];
    
    [_bttMetroLyric setHidden:YES];
    [_bttMetroLyric setState:NSOffState];
    
    [_bttCustom setHidden:YES];
    [_bttCustom setState:NSOffState];
}

#pragma mark - lyricEditorDelegate

- (void)setupLyricEditorWithTrack:(ITrack *)track{
    if (track && track.passedTheQueue){
        [self setTrack:track];
        [_applyButton setHidden:NO];
        [_textScrollView setHidden:NO];
        [_bttLyricWiki setHidden:NO];
        [_bttMetroLyric setHidden:NO];
        
        if (![_track.lyricWiki isEqualToString:@""]){
            [_bttLyricWiki setEnabled:YES];
            [_bttLyricWiki setState:NSOnState];
            [_textView setString:_track.lyricWiki];
        }else{
            [_bttLyricWiki setEnabled:NO];
            [_bttLyricWiki setState:NSOffState];
        }
        
        if (![_track.metroLyrics isEqualToString:@""]){
            [_bttMetroLyric setEnabled:YES];
            if (_bttLyricWiki.state == NSOffState){
                [_textView setString:_track.metroLyrics];
                [_bttMetroLyric setState:NSOnState];
            }else
                [_bttMetroLyric setState:NSOffState];
        }else{
            [_bttMetroLyric setEnabled:NO];
            [_bttMetroLyric setState:NSOffState];
        }
    }else
        [self reset];
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification{
    [self.track setCustomLyric:_textView.string];
    //TODO: test if self.track is realy a pointer to the real track?
    //maybe use @dynamic
    if ([_bttCustom isHidden]){
        [_bttCustom setHidden:NO];
        
        if (_bttLyricWiki.state == NSOnState){
            if (![[_textView string] isEqualToString:_track.lyricWiki])
                [self lyricButton:_bttCustom];
        }else if (_bttMetroLyric.state == NSOnState){
            if (![[_textView string] isEqualToString:_track.metroLyrics])
                [self lyricButton:_bttCustom];
        }
    }
}

@end