//
//  DAPageIndicatorView.m
//  DAPagesContainerScrollView
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAPageIndicatorView.h"


@implementation DAPageIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        _color = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - Public

- (void)setColor:(UIColor *)color
{
    if ([_color isEqual:color]) {
        _color = color;
        [self setNeedsDisplay];
    }
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillPath(context);
}


@end