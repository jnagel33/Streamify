//
//  PlaylistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "PlaylistViewController.h"
#import "SongTableViewCell.h"
#import "AddSongViewController.h"
#import "Song.h"
#import "SpotifyService.h"
#import "AppDelegate.h"

@interface PlaylistViewController () <UITableViewDataSource, UITableViewDelegate, AddSongViewControllerDelegate>

@property(weak, nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *songs;
@property(strong,nonatomic)SpotifyService *spotifyService;

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.spotifyService = [SpotifyService sharedService];
  
  UINib *cellNib = [UINib nibWithNibName:@"PlaylistSongTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"PlaylistSongCell"];
  //Remove later
  self.songs = [[NSMutableArray alloc]init];
}
- (IBAction)addSongPressed:(UIBarButtonItem *)sender {
  [self performSegueWithIdentifier:@"SearchSongs" sender:self];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.songs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistSongCell" forIndexPath:indexPath];
  Song *song = self.songs[indexPath.row];
  [cell configureCell:song];
  
  return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 76;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  Song *song = self.songs[indexPath.row];
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  [self.spotifyService playUsingSession:appDelegate.session AndPlayer:appDelegate.player withTrack:song.uri];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"SearchSongs"]) {
    AddSongViewController *destinationController = segue.destinationViewController;
    destinationController.delegate = self;
  }
}

-(void)addSongToPlaylist:(Song *)song {
  [self.songs addObject:song];
  [self.tableView reloadData];
}

@end
