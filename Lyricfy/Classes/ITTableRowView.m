//
//  ITCustomTableRowView.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "ITTableRowView.h"

@implementation ITTableRowView

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect{
    [[NSColor colorWithCalibratedWhite:.72 alpha:1.0] setStroke];
    [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
    
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:self.bounds];
    [selectionPath fill];
    [selectionPath stroke];
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect{
    if(!self.isGroupRowStyle){
        NSRect separatorRect = [self bounds];
        separatorRect.origin.y = NSMaxY(separatorRect) - 1;
        separatorRect.size.height = 1;
        
        NSColor *targetColor = [NSColor colorWithSRGBRed:.80 green:.80 blue:.80 alpha:1];
        NSArray *colors = @[[targetColor colorWithAlphaComponent:0], targetColor, targetColor, [targetColor colorWithAlphaComponent:0]];
        CGFloat locations[4] = { 0.0, 0.4, 0.7, 1.0 };
        NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
        [gradient drawInRect:separatorRect angle:0];
    }
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect{
    [super drawBackgroundInRect:dirtyRect];
}

- (NSBackgroundStyle)interiorBackgroundStyle{
    return NSBackgroundStyleLight;
}

@end