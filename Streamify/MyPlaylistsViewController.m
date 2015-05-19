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

@interface MyPlaylistsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyPlaylistsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle:@"Back"
                                 style:UIBarButtonItemStylePlain
                                 target:nil
                                 action:nil];
  
  self.navigationItem.backBarButtonItem=backButton;
  
  UINib *cellNib = [UINib nibWithNibName:@"HostedPlaylistTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"HostedPlaylistTableViewCell"];
  cellNib = [UINib nibWithNibName:@"ContributorTableViewCell" bundle:[NSBundle mainBundle]];
  [self.tableView registerNib:cellNib forCellReuseIdentifier:@"ContributorTableViewCell"];
  
}
- (IBAction)addPlaylistButton:(UIBarButtonItem *)sender {
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a Playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
  }];
  [alertController addAction:saveAction];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [self dismissViewControllerAnimated:true completion:nil];
  }];
  [alertController addAction:cancelAction];
  
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
    textField.placeholder = @"Enter new playlist name";
  }];
  [self presentViewController:alertController animated:true completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    HostedPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HostedPlaylistTableViewCell" forIndexPath:indexPath];
    return cell;
  } else {
    ContributorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContributorTableViewCell" forIndexPath:indexPath];
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
    return @"Host";
  } else {
    return @"Contributor";
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  PlaylistHeaderView *headerView = [[PlaylistHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
  UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 7, self.view.frame.size.width, 16)];
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.font = [UIFont fontWithName:@"Avenir" size:20];
  headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
  [headerView addSubview:headerLabel];
  
  return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:true];
  [self performSegueWithIdentifier:@"ShowPlaylist" sender:self];
}

@end
