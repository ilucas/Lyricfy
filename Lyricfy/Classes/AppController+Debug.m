//
//  AppController+DEV.m
//  Lyricfy
//
//  Created by Lucas on 2/23/13.
//  Copyright (c) 2013 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "AppController+Debug.h"
#import "TableViewController.h"
#import "GroupRowItem.h"
#import "iTunes.h"
#import "ITrack.h"

@implementation AppController (DEV)

- (void)activateDebugMenu{
    NSMenu *debugMenu = [[NSMenu alloc] initWithTitle:@"Debug"];
    NSMenuItem *theItem;
    
    theItem = [debugMenu addItemWithTitle:@"Fill TableView" action:@selector(fillTableViewWithRandomTracks:) keyEquivalent:@""];
	[theItem setTarget:self];
    
    theItem = [debugMenu addItemWithTitle:@"Random Action" action:@selector(randomAction:) keyEquivalent:@""];
	[theItem setTarget:self];
    
    NSMenuItem *debugMenuItem = [[NSApp mainMenu] addItemWithTitle:@"Debug" action:nil keyEquivalent:@""];
	[debugMenuItem setSubmenu:debugMenu];
}

- (IBAction)randomAction:(id)sender{
    [self.tableViewController.tableView reloadData];
}

- (IBAction)fillTableViewWithRandomTracks:(id)sender{

}


@end
