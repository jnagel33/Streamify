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

@interface AddSongViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddSongViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.searchBar.delegate = self;
  
  
  UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
  searchField.textColor = [UIColor whiteColor];
  
  self.spotifyService = [[SpotifyService alloc]init];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.songs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
  Song *song = self.songs[indexPath.row];
  [cell configureCell:song];
  return cell;
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
    [self.spotifyService getTracksFromSearchTerm:searchBar.text completionHandler:^(NSArray *tracks) {
      self.songs = tracks;
      [self.tableView reloadData];
    }];
  }
}

@end
