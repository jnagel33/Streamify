//
//  ArtistViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ArtistViewController.h"
#import "ArtistSongTableViewCell.h"
#import "StreamifyService.h"
#import "Artist.h"
#import "PlaylistHeaderView.h"
#import "RelatedArtistsViewController.h"

@interface ArtistViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *artistImageView;
@property (weak, nonatomic) IBOutlet UILabel *artistNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic)StreamifyService *streamifyService;

@property(strong,nonatomic)NSArray *topTracks;

@end

@implementation ArtistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = self.selectedArtist.name;
  
  self.artistImageView.layer.cornerRadius = 150 / 2;
  self.artistImageView.layer.masksToBounds = true;
  self.artistImageView.image = self.selectedArtist.artistImage;
  self.artistNameTextField.text = self.selectedArtist.name;
  
  self.streamifyService = [StreamifyService sharedService];
  [self.streamifyService findArtistTopTracks:self.selectedArtist.artistID completionHandler:^(NSArray *songs) {
    self.topTracks = songs;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
  }];
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"RelatedArtistCell"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelatedArtistCell" forIndexPath:indexPath];
    cell.textLabel.text = @"Find Related Artists";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.contentView.backgroundColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
  } else {
    ArtistSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistSongCell" forIndexPath:indexPath];
    Song *song = self.topTracks[indexPath.row];
    [cell configureCell:song];
    return cell;
  }
}

#pragma mark - Table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  [self performSegueWithIdentifier:@"ShowRelatedArtists" sender:self];
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

@end
