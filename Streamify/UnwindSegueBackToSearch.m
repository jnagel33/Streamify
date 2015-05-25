//
//  UnwindSegueBackToSearch.m
//  Streamify
//
//  Created by Josh Nagel on 5/21/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "UnwindSegueBackToSearch.h"
#import "ArtistViewController.h"
#import "SearchArtistsViewController.h"
#import "ArtistCollectionViewCell.h"
#import "Artist.h"
#import "RelatedArtistsViewController.h"

@implementation UnwindSegueBackToSearch

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}


-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  ArtistViewController *fromVC = (ArtistViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  SearchArtistsViewController *toVC = (SearchArtistsViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  
  UIView *containerView = [transitionContext containerView];
  toVC.view.alpha = 0;
  fromVC.artistImageView.alpha = 0;
  [containerView addSubview:toVC.view];
  
  NSIndexPath *indexPath = fromVC.selectedIndexPath;
  ArtistCollectionViewCell *cell = (ArtistCollectionViewCell *)[toVC.collectionView cellForItemAtIndexPath:indexPath];
  UIView *snapShot = [fromVC.artistImageView snapshotViewAfterScreenUpdates:false];
  cell.hidden = true;
  
  
  snapShot.frame = [containerView convertRect:fromVC.artistImageView.frame fromCoordinateSpace:fromVC.artistImageView.superview];
  [containerView addSubview:snapShot];
  [toVC.view layoutIfNeeded];
  
  CGRect frame = [containerView convertRect:cell.artistImageView.frame fromView:cell];
  
  
  [UIView animateWithDuration:0.4 animations:^{
    toVC.view.alpha = 1;
    snapShot.frame = frame;
  } completion:^(BOOL finished) {
    if (finished) {;
      cell.hidden = false;
      [snapShot removeFromSuperview];
      [transitionContext completeTransition:true];
    } else {
      [transitionContext completeTransition:false];
    }
  }];
}

@end
