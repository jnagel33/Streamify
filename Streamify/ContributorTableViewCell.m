//
//  ContributorTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ContributorTableViewCell.h"
#import "Playlist.h"
#import "User.h"

@interface ContributorTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistCreator;


@end

@implementation ContributorTableViewCell

-(void)configureCell:(Playlist *)playlist {
  self.playlistNameLabel.text = nil;
  self.numberOfSongsLabel.text = nil;
  self.playlistCreator.text = nil;
  
  self.playlistNameLabel.text = playlist.name;
  self.numberOfSongsLabel.text = playlist.host.username;
  
}

@end
