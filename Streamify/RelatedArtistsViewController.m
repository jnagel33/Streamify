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
#import "StreamifyService.h"
#import "Artist.h"

@interface RelatedArtistsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(strong,nonatomic)NSArray *artists;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong,nonatomic)StreamifyService *streamifyService;

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
  
  self.streamifyService = [StreamifyService sharedService];
  [self.streamifyService findRelatedArtists:self.selectedArtist.artistID completionHandler:^(NSArray *artists) {
    self.artists = artists;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
  }];
  
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
  [collectionView deselectItemAtIndexPath:indexPath animated:true];
  Artist *artist = self.artists[indexPath.row];
  ArtistViewController *artistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ArtistProfile"];
  artistVC.selectedArtist = artist;
  [self.navigationController pushViewController:artistVC animated:true];
}

@end
