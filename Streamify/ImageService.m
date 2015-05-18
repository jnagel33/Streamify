//
//  ImageService.m
//  Streamify
//
//  Created by Josh Nagel on 5/18/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ImageService.h"
#import <UIKit/UIKit.h>

@implementation ImageService

+(id)sharedService {
  static ImageService *mySharedService = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[self alloc] init];
  });
  return mySharedService;
}

-(UIImage *)getImageFromURL:(NSString *)urlStr {
  NSURL *url = [NSURL URLWithString:urlStr];
  NSData *imageData = [[NSData alloc]initWithContentsOfURL:url];
  return [UIImage imageWithData:imageData];
}

@end
