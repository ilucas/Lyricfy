//
//  RBLClipView.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-09-14.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLClipView.h"
#import "KGNoise.h"

@implementation RBLClipView
@dynamic layer;

#pragma mark Properties

- (NSColor *)backgroundColor {
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)color {
    [self.layer setBackgroundColor:[color CGColor]];
}

- (BOOL)isOpaque {
	return self.layer.opaque;
}

- (void)setOpaque:(BOOL)opaque {
    [self.layer setOpaque:opaque];
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayer:[CAScrollLayer layer]];
        [self setWantsLayer:YES];
        
        [self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawNever];
        
        //Matches default NSClipView settings.
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:YES];
    }
    return self;
}

@end
