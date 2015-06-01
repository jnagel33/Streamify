//
//  RelatedArtistsViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "RelatedArtistsViewController.h"
#import "ArtistCollectionViewCell.h"
#import "ArtistViewController.h"
#import "SpotifyService.h"
#import "Artist.h"
#import "ToArtistViewController.h"


@interface RelatedArtistsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate>

@property(strong,nonatomic)SpotifyService *spotifyService;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation RelatedArtistsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem=backButton;
  [self.activityIndicator startAnimating];
  self.spotifyService = [SpotifyService sharedService];
  [self.spotifyService findRelatedArtists:self.selectedArtist.artistID completionHandler:^(NSArray *artists) {
    self.artists = artists;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.activityIndicator stopAnimating];
  }];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationController.delegate = nil;
}

#pragma mark - Collection view data source

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ArtistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedArtistCell" forIndexPath:indexPath];
  Artist *artist = self.artists[indexPath.row];
  [cell configureCell:artist];
  return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.artists.count;
}

#pragma mark - Collection view delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  Artist *artist = self.artists[indexPath.row];
  ArtistViewController *artistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ArtistProfile"];
  artistVC.selectedArtist = artist;
  [self.navigationController pushViewController:artistVC animated:true];
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
  if ([toVC isKindOfClass:[ArtistViewController class]]) {
    ToArtistViewController *toArtistVC = [[ToArtistViewController alloc]init];
    toArtistVC.relatedArtistTransition = true;
    return [[ToArtistViewController alloc]init];
  }
  return nil;
}

@end
