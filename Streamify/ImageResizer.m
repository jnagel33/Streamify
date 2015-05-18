//
//  ImageResizer.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ImageResizer.h"
#import <UIKit/UIKit.h>

@implementation ImageResizer

+(UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resizedImage;
}

@end
