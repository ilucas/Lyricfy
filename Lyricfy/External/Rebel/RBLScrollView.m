//
//  RBLScrollView.m
//  Rebel
//
//  Created by Jonathan Willing on 12/4/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLScrollView.h"
#import "RBLClipView.h"

@implementation RBLScrollView

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self swapClipView];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	if (![self.contentView isKindOfClass:[RBLClipView class]])
		[self swapClipView];
}

#pragma mark Clip view swapping

- (void)swapClipView {
    [self setWantsLayer:YES];
	id documentView = self.documentView;
	RBLClipView *clipView = [[RBLClipView alloc] initWithFrame:self.contentView.frame];
    [self setContentView:clipView];
    [self setDocumentView:documentView];
}

@end
