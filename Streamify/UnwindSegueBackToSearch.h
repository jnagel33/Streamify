//
//  UnwindSegueBackToSearch.h
//  Streamify
//
//  Created by Josh Nagel on 5/21/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnwindSegueBackToSearch : NSObject <UIViewControllerAnimatedTransitioning>

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
