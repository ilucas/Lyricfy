//
//  GeneralPreferencesViewController.m
//  Lyricfy
//
//  Created by Lucas on 19/05/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "GeneralPreferencesViewController.h"

@interface GeneralPreferencesViewController ()
- (IBAction)lyricAction:(id)sender;
@end

@implementation GeneralPreferencesViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.lyricsFreak setEnabled:false];//not implemented
        [self.imgv setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    }    
    return self;
}

- (id)init{
    self = [self initWithNibName:@"GeneralPreferencesView" bundle:nil];
    return self;
}

#pragma mark - MASPreferencesViewController

- (NSString *)identifier{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel{
    return @"General";
}

- (void)viewWillAppear{
    [self.imgv setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.lyricWiki setState:[defaults boolForKey:kLyricWiki]];
    [self.metroLyrics setState:[defaults boolForKey:kMetroLyrics]];
    [self.lyricsFreak setState:[defaults boolForKey:kLyricsFreak]];
}

#pragma mark - UI

- (IBAction)lyricAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([sender tag]){
        case 0://LyricWiki
            if ([(NSButton *)sender state] == NSOnState)
                [defaults setBool:true forKey:kLyricWiki];
            else
                [defaults setBool:false forKey:kLyricWiki];
            break;
        case 1://MetroLyric
            if ([(NSButton *)sender state] == NSOnState)
                [defaults setBool:true forKey:kMetroLyrics];
            else
                [defaults setBool:false forKey:kMetroLyrics];
            break;
        case 2://LyricsFreak
            if ([(NSButton *)sender state] == NSOnState)
                [defaults setBool:true forKey:kLyricsFreak];
            else
                [defaults setBool:false forKey:kLyricsFreak];
            break;
        default:
            break;
    }
    [defaults synchronize];
}

@end
