//
//  ToArtistViewController.h
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToArtistViewController : NSObject <UIViewControllerAnimatedTransitioning>

@property(nonatomic)bool relatedArtistTransition;

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
