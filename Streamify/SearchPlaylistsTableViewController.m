//
//  SearchPlaylistsTableViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/19/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "SearchPlaylistsTableViewController.h"
#import "ContributorTableViewCell.h"
#import "StreamifyService.h"
#import "Playlist.h"
#import "SearchingTableViewCell.h"
#import "NoResultsTableViewCell.h"
#import "PlaylistViewController.h"
#import "User.h"

@interface SearchPlaylistsTableViewController () <UISearchBarDelegate>

@property(strong,nonatomic)NSArray *playlists;
@property(weak, nonatomic)IBOutlet UISearchBar *searchBar;
@property(strong,nonatomic)StreamifyService *streamifyService;
@property(nonatomic)bool isLoading;
@property(nonatomic)bool hasSearched;

@end

@implementation SearchPlaylistsTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.searchBar.delegate = self;
  
  self.streamifyService = [StreamifyService sharedService];
  self.isLoading = false;
  self.hasSearched = false;
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem = backButton;
  
  UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
  searchField.textColor = [UIColor whiteColor];
  
  UINib *cellNib = [UINib nibWithNibName:@"NoResultsTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"NoResultsCell"];
  cellNib = [UINib nibWithNibName:@"SearchingTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"SearchingCell"];
  cellNib = [UINib nibWithNibName:@"ContributorTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"ContributorTableViewCell"];
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ((self.playlists.count == 0 && self.hasSearched) || self.isLoading) {
    return 1;
  }
  return self.playlists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.isLoading) {
    SearchingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchingCell" forIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    return cell;
  } else if (self.playlists.count == 0) {
    NoResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell" forIndexPath:indexPath];
    return cell;
  } else {
    ContributorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContributorTableViewCell" forIndexPath:indexPath];
    Playlist *playlist = self.playlists[indexPath.row];
    [cell configureCell:playlist];
    return cell;
  }
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  PlaylistViewController *playlistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
  playlistVC.currentUser = self.currentUser;
  playlistVC.currentPlaylist = self.playlists[indexPath.row];
  [self.navigationController pushViewController:playlistVC animated:true];

}

#pragma mark - Search Bar delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  if (searchBar.text) {
    self.isLoading = true;
    self.hasSearched = true;
    [self.tableView reloadData];
    [self.streamifyService findPlaylistsWithSearchTerm:searchBar.text completionHandler:^(NSArray *playlists) {
      self.playlists = playlists;
      self.isLoading = false;
      [self.tableView reloadData];
    }];
  }
}

@end
