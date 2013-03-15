//
//  ITCustomTableView.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "ITTableView.h"
#import "KGNoise.h"
#import "RBLClipView.h"

@implementation ITTableView

#pragma mark - Delegate

- (void)setDelegate:(id <ITTableViewDelegate>)delegate{
    [super setDelegate:delegate];
}

- (id <ITTableViewDelegate>)delegate{
    return (id <ITTableViewDelegate>)[super delegate];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    //Drawing superview.
    
    //__weak RBLClipView *sview = (id)[self superview];
    //[sview setBackgroundColor:[NSColor windowBackgroundColor]];
    //[self setBackgroundColor:[NSColor windowBackgroundColor]];
    
    
    //[[NSColor windowBackgroundColor] set];
    //NSRectFill(dirtyRect);
    [KGNoise drawNoiseWithOpacity:0.32 andBlendMode:kCGBlendModeScreen];
    
    /*
    //Draw shadow under the last cell
    //http://forrst.com/posts/NSTableView_Drop_Shadow-O7F
    NSUInteger rowCount = [self numberOfRows];
    if (!rowCount)// if there are no rows, there is no shadow
        return;
    CGFloat rowHeight = [self rowHeight] + [self intercellSpacing].height;
    CGFloat contentHeight = rowHeight * rowCount; // calculate the total content height
    NSRect drawingRect = [self bounds];
    NSRect shadowRect = NSMakeRect(drawingRect.origin.x, contentHeight, drawingRect.size.width, 6.0);
    NSGradient *shadowGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.000 alpha:0.310] endingColor:[NSColor clearColor]]; // fade from black to clear
    [shadowGradient drawInRect:shadowRect angle:90];
    */
}

- (CGFloat)positionPastLastRow {
    //Only draw the grid past the last visible row
    NSInteger numberOfRows = [self numberOfRows];
    CGFloat yStart = 0;
    if (numberOfRows > 0)
        yStart = NSMaxY([self rectOfRow:numberOfRows - 1]);
    
    return yStart;
}

- (void)drawGridInClipRect:(NSRect)clipRect {
    // do nothing looks good

    /*
    // Only draw the grid past the last visible row
    CGFloat yStart = [self yPositionPastLastRow];
    // Draw the first separator one row past the last row
    yStart += self.rowHeight;
    
    // One thing to do is smarter clip testing to see if we actually need to draw!
    NSRect boundsToDraw = clipRect;
    NSRect separatorRect = boundsToDraw;
    separatorRect.size.height = 1;
    while (yStart < NSMaxY(boundsToDraw)) {
        separatorRect.origin.y = yStart;
        NSColor *targetColor = [NSColor colorWithSRGBRed:.80 green:.80 blue:.80 alpha:1];
        NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0], targetColor, targetColor, [targetColor colorWithAlphaComponent:0], nil];
        CGFloat locations[4] = { 0.0, 0.35, 0.65, 1.0 };
        NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
        [gradient drawInRect:separatorRect angle:0];
        yStart += self.rowHeight;
    }
    */
}

#pragma mark - Events

- (void)keyDown:(NSEvent *)theEvent{
    [super keyDown:theEvent];
    // Check if the event was a keypress that match the delete key.
    if ([theEvent type] == NSKeyDown){
        const unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];//Pressed key
        if (key == NSDeleteCharacter){
            NSInteger row = [self selectedRow];
            if (row != -1){
                if ([[self delegate] respondsToSelector:@selector(tableView:shouldDeleteRow:)]){
                    if([[self delegate] tableView:self shouldDeleteRow:row])
                        [self removeRowAtIndex:row];
                }
            }
        }
    }
}

- (void)removeRowAtIndex:(NSInteger)index{
    if (index > -1 && index <= self.numberOfRows){
        //if the tableview's window is not visible, there's no need to animate.
        NSTableViewAnimationOptions animation = ([[self window] isVisible] ? NSTableViewAnimationEffectFade : NSTableViewAnimationEffectNone);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
            [self beginUpdates];
            [self removeRowsAtIndexes:indexSet withAnimation:animation];
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:-1] byExtendingSelection:NO];//leave the selection empty
            [self endUpdates];
        });
    }
}

- (void)removeRowAtIndex:(NSInteger)index withAnimation:(NSTableViewAnimationOptions)animationOptions{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self removeRowsAtIndexes:indexSet withAnimation:animationOptions];
}

- (void)insertRowAtIndex:(NSInteger)index withAnimation:(NSTableViewAnimationOptions)animationOptions{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self insertRowsAtIndexes:indexSet withAnimation:animationOptions];
}

@end