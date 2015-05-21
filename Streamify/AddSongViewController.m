//
//  AddSongViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "AddSongViewController.h"
#import "SpotifyService.h"
#import "SongTableViewCell.h"
#import "AddSongViewControllerDelegate.h"
#import "NoResultsTableViewCell.h"
#import "SearchingTableViewCell.h"

@interface AddSongViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property(weak, nonatomic)IBOutlet UISearchBar *searchBar;
@property(nonatomic)bool isLoading;
@property(nonatomic)bool hasSearched;

@end

@implementation AddSongViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.searchBar.delegate = self;
  
  self.isLoading = false;
  self.hasSearched = false;
  
  UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
  searchField.textColor = [UIColor whiteColor];
  
  UINib *cellNib = [UINib nibWithNibName:@"NoResultsTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"NoResultsCell"];
  cellNib = [UINib nibWithNibName:@"SearchingTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"SearchingCell"];
  
  self.spotifyService = [SpotifyService sharedService];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ((self.songs.count == 0 && self.hasSearched) || self.isLoading) {
    return 1;
  }
  return self.songs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.isLoading) {
    SearchingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchingCell" forIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    return cell;
  } else if (self.songs.count == 0) {
    NoResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell" forIndexPath:indexPath];
    return cell;
  } else {
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    Song *song = self.songs[indexPath.row];
    [cell configureCell:song];
    return cell;
  }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  Song *song = self.songs[indexPath.row];
  [self.delegate addSongToPlaylist:song];
  [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  if (searchBar.text) {
    self.isLoading = true;
    self.hasSearched = true;
    [self.tableView reloadData];
    [self.spotifyService getTracksFromSearchTerm:searchBar.text completionHandler:^(NSArray *tracks) {
      self.songs = tracks;
      self.isLoading = false;
      [self.tableView reloadData];
    }];
  }
}

@end
