//
//  ArtistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ArtistViewController.h"
#import "ArtistSongTableViewCell.h"
#import "Artist.h"
#import "PlaylistHeaderView.h"
#import "RelatedArtistsViewController.h"
#import "IconDetailTableViewCell.h"
#import "SearchArtistsViewController.h"
#import "UnwindSegueBackToSearch.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "Song.h"
#import "SpotifyService.h"


@interface ArtistViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *artistNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)SpotifyService *spotifyService;
@property(strong,nonatomic)NSArray *topTracks;
@property(strong,nonatomic)SPTAudioStreamingController *player;
@property(strong,nonatomic)SPTSession *session;
@property(nonatomic)NSInteger rowPlaying;

@end

@implementation ArtistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  
  self.navigationItem.backBarButtonItem=backButton;
  
  self.navigationItem.title = self.selectedArtist.name;
  
  self.artistImageView.layer.cornerRadius = 150 / 2;
  self.artistImageView.layer.masksToBounds = true;
  self.artistImageView.image = self.selectedArtist.artistImage;
  self.artistNameTextField.text = self.selectedArtist.name;
  
  self.spotifyService = [SpotifyService sharedService];
  [self.spotifyService findArtistTopTracks:self.selectedArtist.artistID completionHandler:^(NSArray *songs) {
    self.topTracks = songs;
    [self.tableView reloadData];
  }];
  
  UINib *cellNib = [UINib nibWithNibName:@"IconDetailTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"RelatedArtistCell"];
  
  AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
  self.session = appDelegate.session;
  self.player = appDelegate.player;
  
  self.rowPlaying = 99;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.navigationController.delegate = nil;
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  }
  return self.topTracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    IconDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelatedArtistCell" forIndexPath:indexPath];
    [cell configureCell:[UIImage imageNamed:@"ArtistIcon"] AndDetailText:@"Find Related Artists"];
    return cell;
  } else {
    ArtistSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistSongCell" forIndexPath:indexPath];
    Song *song = self.topTracks[indexPath.row];
    
    if (self.rowPlaying == indexPath.row) {
      [cell configureCell:song rowPlaying:true];
    } else {
      [cell configureCell:song rowPlaying:false];
    }
    return cell;
  }
}

#pragma mark - Table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  if (indexPath.section == 0) {
    [self performSegueWithIdentifier:@"ShowRelatedArtists" sender:self];
  } else {
    Song *song = self.topTracks[indexPath.row];
    self.rowPlaying = indexPath.row;
    [self.tableView reloadData];
    NSArray *uris = [[NSArray alloc]initWithObjects:[NSURL URLWithString:song.uri], nil];
    [self.player playURIs:uris fromIndex:0 callback:^(NSError *error) {
      if (error != nil) {
        NSLog(@"*** Starting playback got error: %@", error);
        return;
      }
    }];
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"Related";
  } else {
    return @"Top Tracks";
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  PlaylistHeaderView *headerView = [[PlaylistHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
  UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, 25)];
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.font = [UIFont fontWithName:@"Avenir" size:20];
  headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
  [headerView addSubview:headerLabel];
  return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 35;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ShowRelatedArtists"]) {
    RelatedArtistsViewController *destinationVC = segue.destinationViewController;
    destinationVC.selectedArtist = self.selectedArtist;
  }
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
  if ([toVC isKindOfClass:[SearchArtistsViewController class]]) {
    return [[UnwindSegueBackToSearch alloc]init];
  } else {
    return nil;
  }
}

@end
