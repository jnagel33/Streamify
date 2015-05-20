//
//  DiscoverTableViewController.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "DiscoverTableViewController.h"
#import "SearchArtistsViewController.h"
#import "PlaylistHeaderView.h"

@interface DiscoverTableViewController ()

@end

@implementation DiscoverTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    [self performSegueWithIdentifier:@"FindArtists" sender:self];
  } else {
    SearchArtistsViewController *searchArtistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ArtistSearch"];
    searchArtistsVC.isGenreSearch = true;
    [self.navigationController pushViewController:searchArtistsVC animated:true];
  }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    PlaylistHeaderView *headerView = [[PlaylistHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, 25)];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    headerLabel.text = @"Artist";
    [headerView addSubview:headerLabel];
    return headerView;
  } else {
    PlaylistHeaderView *headerView = [[PlaylistHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    return headerView;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 35;
  }
  return 5;
}


@end
