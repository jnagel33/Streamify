//
//  ArtistSongTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ArtistSongTableViewCell.h"
#import "Song.h"

@interface ArtistSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *popularityLabel;

@end

@implementation ArtistSongTableViewCell


-(void)configureCell:(Song *)song {
  self.trackNameLabel.text = nil;
  self.popularityLabel.text = nil;
  
  self.trackNameLabel.text = song.trackName;
  self.popularityLabel.text = [NSString stringWithFormat:@"%@",song.popularity];
}

@end
