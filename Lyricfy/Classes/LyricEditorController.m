//
//  lyricEditorController.m
//  Lyricfy
//
//  Created by Lucas on 11/23/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "LyricEditorController.h"
#import "ITrack.h"
#import "iTunes.h"

@interface LyricEditorController ()
@property (nonatomic, weak) ITrack *track;
@end

@implementation LyricEditorController
@synthesize delegate;

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
}

- (void)awakeFromNib{
    [self resetEditorView];
}

#pragma mark - UI

- (IBAction)applyButton:(id)sender {
    ITSource sauce = ITmetroLyrics; //for now metroLyrics is the default
    if (self.bttCustom.state == NSOnState)
        sauce = ITCustomLyric;
    else if (self.bttLyricWiki.state == NSOnState)
        sauce = ITLyricWiki;
    else if (self.bttMetroLyric.state == NSOnState)
        sauce = ITmetroLyrics;
        
    [delegate applyLyric:sauce forTrack:self.track];
    [self resetEditorView];
}

- (IBAction)lyricButton:(id)sender{
    switch ([sender tag]){
        case 0://LyricWiki
            [self.bttLyricWiki setState:NSOnState];
            [self.bttMetroLyric setState:NSOffState];
            [self.bttCustom setState:NSOffState];
            [self.textView setString:self.track.lyricWiki];
            break;
        case 1://MetroLyric
            [self.bttLyricWiki setState:NSOffState];
            [self.bttMetroLyric setState:NSOnState];
            [self.bttCustom setState:NSOffState];
            [self.textView setString:self.track.metroLyrics];
            break;
        case 2://Custom
            [self.bttLyricWiki setState:NSOffState];
            [self.bttMetroLyric setState:NSOffState];
            [self.bttCustom setState:NSOnState];
            [self.textView setString:self.track.customLyric];
            break;
        default:
            break;
    }
}

- (void)resetEditorView{
    [self.applyButton setHidden:YES];
    [self.textScrollView setHidden:YES];
    [self.textView setString:@""];

    [self.bttLyricWiki setHidden:YES];
    [self.bttLyricWiki setState:NSOffState];
    
    [self.bttMetroLyric setHidden:YES];
    [self.bttMetroLyric setState:NSOffState];
    
    [self.bttCustom setHidden:YES];
    [self.bttCustom setState:NSOffState];
}

#pragma mark - lyricEditorDelegate

- (void)setupLyricEditorWithTrack:(ITrack *)track{
    if (track && track.passedTheQueue){
        [self setTrack:track];
        [self.applyButton setHidden:NO];
        [self.textScrollView setHidden:NO];
        [self.bttLyricWiki setHidden:NO];
        [self.bttMetroLyric setHidden:NO];
        
        if (![self.track.lyricWiki isEqualToString:@""]){
            [self.bttLyricWiki setEnabled:YES];
            [self.bttLyricWiki setState:NSOnState];
            [self.textView setString:self.track.lyricWiki];
        }else{
            [self.bttLyricWiki setEnabled:NO];
            [self.bttLyricWiki setState:NSOffState];
        }
        
        if (![self.track.metroLyrics isEqualToString:@""]){
            [self.bttMetroLyric setEnabled:YES];
            if (self.bttLyricWiki.state == NSOffState){
                [self.textView setString:self.track.metroLyrics];
                [self.bttMetroLyric setState:NSOnState];
            }else
                [self.bttMetroLyric setState:NSOffState];
        }else{
            [self.bttMetroLyric setEnabled:NO];
            [self.bttMetroLyric setState:NSOffState];
        }
    }else
        [self resetEditorView];
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)notification{
    [self.track setCustomLyric:self.textView.string];
    if ([self.bttCustom isHidden]){
        [self.bttCustom setHidden:NO];
        
        if (self.bttLyricWiki.state == NSOnState){
            if (![[self.textView string] isEqualToString:self.track.lyricWiki])
                [self lyricButton:self.bttCustom];
        }else if (self.bttMetroLyric.state == NSOnState){
            if (![[self.textView string] isEqualToString:self.track.metroLyrics])
                [self lyricButton:self.bttCustom];
        }
    }
}

@end