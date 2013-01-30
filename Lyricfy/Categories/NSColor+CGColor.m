//
//  NSColor+CGColor.m
//  Cocoa+Extensions
//
//  Code by:indragiek
//  http://forrst.com/posts/CGColor_Additions_for_NSColor-1eW
//

#import "NSColor+CGColor.h"
#import <objc/runtime.h>

@implementation NSColor (CGColor)

- (CGColorRef)CGColor{
    NSColor *colorRGB = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat components[4];
    [colorRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef theColor = CGColorCreate(theColorSpace, components);
    CGColorSpaceRelease(theColorSpace);
    return theColor;
}

+ (NSColor*)colorWithCGColor:(CGColorRef)aColor{
    if (aColor == NULL)
        return nil;
    
    const CGFloat *components = CGColorGetComponents(aColor);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = components[3];
    return [self colorWithDeviceRed:red green:green blue:blue alpha:alpha];     
}

@end