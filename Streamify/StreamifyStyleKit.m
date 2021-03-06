//
//  StreamifyStyleKit.m
//  StreamifyStyleKit
//
//  Created by jnagel on 5/17/15.
//  Copyright (c) 2015 . All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "StreamifyStyleKit.h"


@implementation StreamifyStyleKit

#pragma mark Cache

static UIColor* _spotifyGreen = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _spotifyGreen = [UIColor colorWithRed: 0.424 green: 0.612 blue: 0.106 alpha: 1];

}

#pragma mark Colors

+ (UIColor*)spotifyGreen { return _spotifyGreen; }

#pragma mark Drawing Methods

+ (void)drawHeaderViewWithFrame: (CGRect)frame
{

    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.00000 + 0.5), floor(CGRectGetWidth(frame) * 1.00000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00000 + 0.5), floor(CGRectGetHeight(frame) * 1.00000 + 0.5) - floor(CGRectGetHeight(frame) * 0.00000 + 0.5))];
    [StreamifyStyleKit.spotifyGreen setFill];
    [rectanglePath fill];
}

#pragma mark Generated Images

+ (UIImage*)imageOfHeaderViewWithFrame: (CGRect)frame
{
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0f);
    [StreamifyStyleKit drawHeaderViewWithFrame: frame];

    UIImage* imageOfHeaderView = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageOfHeaderView;
}

@end
