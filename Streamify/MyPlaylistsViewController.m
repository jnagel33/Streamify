//
//  MyPlaylistsViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "MyPlaylistsViewController.h"
#import "ContributorTableViewCell.h"
#import "HostedPlaylistTableViewCell.h"
#import "PlaylistHeaderView.h"
#import "Playlist.h"
#import "User.h"
#import "PlaylistViewController.h"
#import "SearchPlaylistsTableViewController.h"
#import "StreamifyService.h"
#import "IconDetailTableViewCell.h"

@interface MyPlaylistsViewController () <UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic)IBOutlet UITableView *tableView;
@property(strong,nonatomic)NSMutableArray *playlists;
@property(strong,nonatomic)StreamifyService *streamifyService;

@end

@implementation MyPlaylistsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  self.streamifyService = [StreamifyService sharedService];
  
  //remove later
  self.playlists = [[NSMutableArray alloc]init];
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem=backButton;
  
  UINib *cellNib = [UINib nibWithNibName:@"HostedPlaylistTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"HostedPlaylistTableViewCell"];
  cellNib = [UINib nibWithNibName:@"IconDetailTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"HomeIconCell"];
  
  [self.streamifyService findMyPlaylists:^(NSArray *playlists) {
    self.playlists = [[NSMutableArray alloc]initWithArray:playlists];
  }];
  
}
- (IBAction)addPlaylistButton:(UIBarButtonItem *)sender {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    UITextField *playlistNameTextField = alertController.textFields[0];

    Playlist *newPlaylist = [[Playlist alloc]initWithID:nil name:playlistNameTextField.text host:self.currentUser dateCreated:[NSDate date] songs:nil];
    [self.playlists addObject:newPlaylist];
    [self.tableView reloadData];
    [self.streamifyService addPlaylist:newPlaylist completionHandler:^(NSString *playlistID) {
      NSLog(@"DONE");
      newPlaylist.playlistID = playlistID;
    }];
  }];
  [alertController addAction:saveAction];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
  }];
  [alertController addAction:cancelAction];
  
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter new playlist name";
  }];
  [self presentViewController:alertController animated:true completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 2;
  }
  return self.playlists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    HostedPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HostedPlaylistTableViewCell" forIndexPath:indexPath];
    [cell configureCell:self.playlists[indexPath.row]];
    return cell;
  } else {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPlaylists" forIndexPath:indexPath];
    IconDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeIconCell" forIndexPath:indexPath];
    if (indexPath.row == 1) {
      [cell configureCell:[UIImage imageNamed:@"ArtistIcon"] AndDetailText:@"Discover"];
    } else {
      [cell configureCell:[UIImage imageNamed:@"PlaylistIcon"] AndDetailText:@"Search Playlists"];
    }
    return cell;
  }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 80;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"";
  } else {
    return @"My Playlists";
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  PlaylistHeaderView *headerView = [[PlaylistHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
  if (section == 1) {
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, 25)];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:headerLabel];
  }
  return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 35;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      [self performSegueWithIdentifier:@"SearchPlaylists" sender:self];
    } else {
      [self performSegueWithIdentifier:@"ShowDiscover" sender:self];
    }
  } else {
    PlaylistViewController *playlistVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
    playlistVC.currentUser = self.currentUser;
    playlistVC.currentPlaylist = self.playlists[indexPath.row];
    [self.navigationController pushViewController:playlistVC animated:true];
  }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"SearchPlaylists"]) {
    SearchPlaylistsTableViewController *destinationVC = segue.destinationViewController;
    destinationVC.currentUser = self.currentUser;
  }
}

@end
