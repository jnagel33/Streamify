//
//  HostedPlaylistTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/17/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "HostedPlaylistTableViewCell.h"
#import "Playlist.h"
#import "User.h"

@interface HostedPlaylistTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *pendingSuggestionsButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistNameLabel;


@end

@implementation HostedPlaylistTableViewCell

-(void)configureCell:(Playlist *)playlist {
  self.playlistNameLabel.text = nil;
  self.numberOfSongsLabel.text = nil;
  self.playlistNameLabel.text = playlist.name;
  self.numberOfSongsLabel.text = playlist.host.displayName;
}

@end
