//
//  ITCustomTableCellView.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "ITTableCellView.h"
#import "ITrack.h"

@interface ITTableCellView ()
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, assign) CGFloat moveFactor;
@end

@implementation ITTableCellView
@synthesize name, artist;
@synthesize track = _track;

#pragma mark - Lifecycle

- (void)setTrack:(ITrack *)track{
    _track = track;
    [name setStringValue:track.name];
    [artist setStringValue:track.artist];
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAnimationTimer:nil];
    }
    return self;
}

- (void)awakeFromNib{
    [self setMoveFactor:0];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    if ([self.animationTimer isValid]) {
        self.moveFactor = (self.moveFactor > 14.0f ? 0.0f : ++self.moveFactor);
        
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSaveGState(context);
        CGContextClipToRect(context, self.bounds);
        CGMutablePathRef path = CGPathCreateMutable();
        int lines = (self.bounds.size.width/16.0f + self.bounds.size.height);
        for (int i=1; i<=lines; i++) {
            CGPathMoveToPoint(path, NULL, 16.0f * i + -self.moveFactor, 1.0f);
            CGPathAddLineToPoint(path, NULL, 1.0f, 16.0f * i + -self.moveFactor);
        }
        CGContextAddPath(context, path);
        CGPathRelease(path);
        CGContextSetLineWidth(context, 6.0f);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [[NSColor colorWithDeviceWhite:0.5 alpha:0.1] CGColor]);
        //CGContextSetStrokeColorWithColor(context, [[NSColor colorWithDeviceWhite:1.0 alpha:0.1] CGColor]);
        CGContextDrawPath(context, kCGPathStroke);
        CGContextRestoreGState(context);
    }
}

- (void)startAnimation{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/40
                                                            block:^{
                                                                [self setNeedsDisplay:YES];
                                                            }
                                                          repeats:YES];
    /*  
     self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/40
                                                           target:self
                                                         selector:@selector(setNeedsDisplay:)
                                                         userInfo:nil
                                                          repeats:YES];
     */
}

- (void)stopAnimation{
    if (self.animationTimer){
        [self.animationTimer invalidate];
        [self setAnimationTimer:nil];
    }
}

@end