//
//  SearchArtistsViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "SearchArtistsViewController.h"
#import "Artist.h"
#import "ArtistCollectionViewCell.h"
#import "ArtistViewController.h"
#import "ToArtistViewController.h"
#import "SpotifyService.h"

@interface SearchArtistsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SearchArtistsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.searchBar.delegate = self;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  
  if (self.isGenreSearch) {
    self.navigationItem.title = @"Find Artists By Genre";
  }
  
  UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
  searchField.textColor = [UIColor whiteColor];
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem = backButton;
  
  self.spotifyService = [SpotifyService sharedService];
  
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
  ArtistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArtistCell" forIndexPath:indexPath];
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

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  if (searchBar.text) {
    [self.activityIndicator startAnimating];
    if (!self.isGenreSearch) {
      [self.spotifyService findArtistsWithSearchTerm:searchBar.text completionHandler:^(NSArray *artists) {
        self.artists = artists;
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
      }];
    } else {
      [self.spotifyService findArtistsWithGenreSearchTerm:searchBar.text completionHandler:^(NSArray *artists) {
        self.artists = artists;
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
      }];
    }
  }
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
  if ([toVC isKindOfClass:[ArtistViewController class]]) {
    return [[ToArtistViewController alloc]init];
  }
  return nil;
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)sender {
  
}


@end
