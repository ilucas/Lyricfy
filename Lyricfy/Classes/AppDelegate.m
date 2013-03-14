//
//  AppDelegate.m
//  Lyricfy
//
//  Created by Lucas on 11/12/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "AppDelegate.h"
#import "INAppStoreWindow.h"
#import "KGNoise.h"

static const CGFloat SVminConstrain = 296.0;
static const CGFloat SVmaxConstrain = 470.0;

@implementation AppDelegate
@synthesize window, splitView;

#pragma mark - Lifecycle

- (void)awakeFromNib{
    
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [window setTitleBarHeight:40.0];
    [window setTrafficLightButtonsLeftMargin:12.0];
    
    KGNoiseView __weak *tableSide = [[splitView subviews] objectAtIndex:0];
    KGNoiseView __weak *editorSide = [[splitView subviews] objectAtIndex:1];
    
    [editorSide setBackgroundColor:[NSColor windowBackgroundColor]];
    [editorSide setNoiseOpacity:0.3];
    [editorSide setNoiseBlendMode:kCGBlendModeScreen];
    
    [tableSide setBackgroundColor:[NSColor blackColor]];
    
    //Setup CoreData using Magical Records
    //[MagicalRecord setupCoreDataStack];
    
    //DEV: show Constraints Helper
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    //Let's share the applicationDidFinishLaunching
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidFinishLaunching object:aNotification];
}

- (void)applicationWillTerminate:(NSNotification *)notification{
    //[MagicalRecord cleanUp];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    if (flag){
        return NO;
    }else {
        [window makeKeyAndOrderFront:nil];
        return YES;
    }
}

#pragma mark - NSSplitView Delegation

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex{
    return SVminConstrain;
    //return lockedPositionForSplitView(sender);
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    return SVmaxConstrain;
    //return lockedPositionForSplitView(sender);
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize{
    if ([sender inLiveResize]){
        NSRect tmpRect = [sender bounds];
        NSArray *subviews = [sender subviews];
        NSView *tableSide = [subviews objectAtIndex:0];
        NSView *editorSide = [subviews objectAtIndex:1];
        
        CGFloat tableWidth = tableSide.bounds.size.width;
        
        tmpRect.size.width = (tmpRect.size.width - tableWidth - sender.dividerThickness);
        
        tmpRect.origin.x = (tmpRect.origin.x + tableWidth + sender.dividerThickness);
        [editorSide setFrame:tmpRect];//Resize the editor frame
        
        //table frame stay the same size
        tmpRect.size.width = tableWidth;
        tmpRect.origin.x = 0;
        [tableSide setFrame:tmpRect];
    }
    [sender adjustSubviews];
}

CGFloat lockedPositionForSplitView(NSSplitView *sender) {
    NSRect frame = [[[sender subviews] objectAtIndex:0] frame];
    return frame.size.width;
}

@end