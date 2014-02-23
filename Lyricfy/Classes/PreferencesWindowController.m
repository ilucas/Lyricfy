//
//  PreferencesWindowController.m
//  Lyricfy
//
//  Created by Lucas on 19/05/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "PreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (id)init{
    NSViewController *generalVC = [[GeneralPreferencesViewController alloc] init];
    NSArray *controllers = [NSArray arrayWithObjects:[NSNull null], generalVC, [NSNull null], nil];
    self = [super initWithViewControllers:controllers title:@"Preferences"];
    return self;
}

@end
