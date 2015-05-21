//
//  ToArtistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ToArtistViewController.h"
#import "ArtistViewController.h"
#import "SearchArtistsViewController.h"
#import "ArtistCollectionViewCell.h"
#import "Artist.h"
#import "RelatedArtistsViewController.h"

@implementation ToArtistViewController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.5;
}


-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  
  if (self.relatedArtistTransition) {
    RelatedArtistsViewController *fromVC = (RelatedArtistsViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ArtistViewController *toVC = (ArtistViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    toVC.view.alpha = 0;
    [containerView addSubview:toVC.view];
    
    NSIndexPath *indexPath = fromVC.collectionView.indexPathsForSelectedItems.firstObject;
    ArtistCollectionViewCell *cell = (ArtistCollectionViewCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];
    Artist *artist = fromVC.artists[indexPath.row];
    UIImageView *snapShot = [[UIImageView alloc]initWithImage:artist.artistImage];
    cell.hidden = true;
    
    snapShot.frame = [containerView convertRect:cell.artistImageView.frame fromCoordinateSpace:cell.artistImageView.superview];
    snapShot.layer.cornerRadius = snapShot.frame.size.width / 2;
    snapShot.layer.masksToBounds = true;
    [containerView addSubview:snapShot];
    [toVC.view layoutIfNeeded];
    
    toVC.artistImageView.hidden = true;
    
    
    [UIView animateWithDuration:0.4 animations:^{
      toVC.view.alpha = 1;
      snapShot.center = toVC.artistImageView.center;
    } completion:^(BOOL finished) {
      if (finished) {
        toVC.artistImageView.hidden = false;
        [snapShot removeFromSuperview];
        cell.hidden = false;
        [transitionContext completeTransition:true];
      } else {
        [transitionContext completeTransition:false];
      }
    }];

  } else {
    
    SearchArtistsViewController *fromVC = (SearchArtistsViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ArtistViewController *toVC = (ArtistViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    
    toVC.view.alpha = 0;
    [containerView addSubview:toVC.view];
    
    NSIndexPath *indexPath = fromVC.collectionView.indexPathsForSelectedItems.firstObject;
    toVC.selectedIndexPath = indexPath;
    ArtistCollectionViewCell *cell = (ArtistCollectionViewCell *)[fromVC.collectionView cellForItemAtIndexPath:indexPath];
    Artist *artist = fromVC.artists[indexPath.row];
    UIImageView *snapShot = [[UIImageView alloc]initWithImage:artist.artistImage];
    cell.hidden = true;
    
    snapShot.frame = [containerView convertRect:cell.artistImageView.frame fromCoordinateSpace:cell.artistImageView.superview];
    snapShot.layer.cornerRadius = snapShot.frame.size.width / 2;
    snapShot.layer.masksToBounds = true;
    [containerView addSubview:snapShot];
    [toVC.view layoutIfNeeded];
    
    toVC.artistImageView.hidden = true;
    
    
    [UIView animateWithDuration:0.4 animations:^{
      toVC.view.alpha = 1;
      snapShot.center = toVC.artistImageView.center;
    } completion:^(BOOL finished) {
      if (finished) {
        toVC.artistImageView.hidden = false;
        [snapShot removeFromSuperview];
        cell.hidden = false;
        [transitionContext completeTransition:true];
      } else {
        [transitionContext completeTransition:false];
      }
    }];
  }
}

@end
