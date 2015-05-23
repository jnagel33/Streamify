//
//  ArtistSongTableViewCell.m
//  Streamify
//
//  Created by Josh Nagel on 5/20/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ArtistSongTableViewCell.h"
#import "Song.h"
#import "StreamifyStyleKit.h"

@interface ArtistSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *popularityLabel;
@property (weak, nonatomic) IBOutlet UIView *currentTrackIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCurrentTrackIndicatorView;


@end

@implementation ArtistSongTableViewCell


-(void)configureCell:(Song *)song rowPlaying:(bool)rowPlaying {
  self.trackNameLabel.text = nil;
  self.popularityLabel.text = nil;
  
  
  if (rowPlaying) {
    self.currentTrackIndicatorView.backgroundColor = [StreamifyStyleKit spotifyGreen];
    self.currentTrackIndicatorView.alpha = 1;
    self.constraintCurrentTrackIndicatorView.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
      [self.contentView layoutIfNeeded];
    }];
  } else {
    self.constraintCurrentTrackIndicatorView.constant = -12;
    self.currentTrackIndicatorView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
      [self.contentView layoutIfNeeded];
    }];
  }
  
  
    self.trackNameLabel.text = song.trackName;
  self.popularityLabel.text = [NSString stringWithFormat:@"%@",song.popularity];
}

@end
