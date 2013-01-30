//
//  NSColor+CGColor.m
//  Cocoa+Extensions
//
//  Code by:indragiek
//  http://forrst.com/posts/CGColor_Additions_for_NSColor-1eW
//

#import <Cocoa/Cocoa.h>

@interface NSColor (CGColor)

@property (readonly) CGColorRef CGColor CF_RETURNS_RETAINED;

//Create new NSColor from a CGColorRef
+ (NSColor *)colorWithCGColor:(CGColorRef)aColor CF_RETURNS_RETAINED;
@end